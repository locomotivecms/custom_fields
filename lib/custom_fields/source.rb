# frozen_string_literal: true

module CustomFields
  module Source
    extend ActiveSupport::Concern

    included do
      cattr_accessor :_custom_fields_for
      self._custom_fields_for = []

      attr_accessor :_custom_fields_diff
      attr_accessor :_custom_field_localize_diff
    end

    # Determines if the relation is enhanced by the custom fields
    #
    # @example the Person class has somewhere in its code this: "custom_fields_for :addresses"
    #   person.custom_fields_for?(:addresses)
    #
    # @param [ String, Symbol ] name The name of the relation.
    #
    # @return [ true, false ] True if enhanced, false if not.
    #
    def custom_fields_for?(name)
      self.class.custom_fields_for?(name)
    end

    # Returns the class enhanced by the custom fields.
    # Be careful, call this method only if the source class
    # has been saved with success.
    #
    # @param [ String, Symbol ] name The name of the relation.
    #
    # @return [ Class ] The modified class.
    #
    def klass_with_custom_fields(name)
      # Rails.logger.debug "[CustomFields] klass_with_custom_fields #{self.send(name).metadata.klass} / #{self.send(name).metadata[:old_klass]}" if defined?(Rails) # DEBUG
      recipe    = custom_fields_recipe_for(name)
      _metadata = send(name)._association
      target    = _metadata.options[:original_klass] || _metadata.klass # avoid to use an already enhanced klass
      target.klass_with_custom_fields(recipe)
    end

    # Returns the ordered list of custom fields for a relation
    #
    # @example the Person class has somewhere in its code this: "custom_fields_for :addresses"
    #   person.ordered_custom_fields(:addresses)
    #
    # @param [ String, Symbol ] name The name of the relation.
    #
    # @return [ Collection ] The ordered list.
    #
    def ordered_custom_fields(name)
      send(:"#{name}_custom_fields").sort { |a, b| (a.position || 0) <=> (b.position || 0) }
    end

    # Returns the recipe (meaning all the rules) needed to
    # build the custom klass
    #
    # @param [ String, Symbol ] name The name of the relation.
    #
    # @return [ Array ] An array of hashes
    #
    def custom_fields_recipe_for(name)
      {
        'name' => "#{relations[name.to_s].class_name.demodulize}#{_id}",
        'rules' => ordered_custom_fields(name).map(&:to_recipe),
        'version' => custom_fields_version(name),
        'model_name' => relations[name.to_s].class_name.constantize.model_name.to_s
      }
    end

    # Returns the number of the version for relation with custom fields
    #
    # @param [ String, Symbol ] name The name of the relation.
    #
    # @return [ Integer ] The version number
    #
    def custom_fields_version(name)
      send(:"#{name}_custom_fields_version") || 0
    end

    # When the fields have been modified and before the object is saved,
    # we bump the version.
    #
    # @param [ String, Symbol ] name The name of the relation.
    #
    def bump_custom_fields_version(name)
      version = custom_fields_version(name) + 1
      send(:"#{name}_custom_fields_version=", version)
    end

    # Change the metadata of a relation enhanced by the custom fields.
    # In Mongoid, all the instances of a same document share the same metadata objects.
    #
    # @param [ String, Symbol ] name The name of the relation.
    #
    def refresh_metadata_with_custom_fields(name)
      return if !persisted? || send(:"#{name}_custom_fields").blank?

      old_metadata = send(name)._association

      # puts "old_metadata = #{old_metadata.klass.inspect} / #{old_metadata.object_id.inspect}" # DEBUG

      # puts "[CustomFields] refresh_metadata_with_custom_fields, #{name.inspect}, self = #{self.inspect}"

      send(name)._association = old_metadata.clone.tap do |metadata|
        # Rails.logger.debug "[CustomFields] refresh_metadata_with_custom_fields #{metadata.klass}" if defined?(Rails) # DEBUG

        # backup the current klass
        metadata.instance_variable_set(:@options, metadata.options.dup)
        metadata.options[:original_klass] ||= metadata.klass

        metadata.instance_variable_set(:@klass, klass_with_custom_fields(name))
      end
      set_attribute_localization(name)
      # puts "new_metadata = #{self.send(name).metadata.klass.inspect} / #{self.send(name).metadata.object_id.inspect}" # DEBUG
    end

    def set_attribute_localization(name)
      klass_name = name.singularize.to_sym
      send(:"#{name}_custom_fields").each do |cf|
        I18n.backend.store_translations ::I18n.locale,
                                        { mongoid: { attributes: { klass_name => { cf.name.to_sym => cf.label } } } }
      end
    end

    # Initializes the object tracking the modifications
    # of the custom fields
    #
    # @param [ String, Symbol ] name The name of the relation.
    #
    def initialize_custom_fields_diff(name)
      self._custom_field_localize_diff ||= Hash.new([])

      self._custom_fields_diff ||= {}
      self._custom_fields_diff[name] = { '$set' => {}, '$unset' => {}, '$rename' => {} }
    end

    # Collects all the modifications of the custom fields
    #
    # @param [ String, Symbol ] name The name of the relation.
    #
    # @return [ Array ] An array of hashes storing the modifications
    #
    def collect_custom_fields_diff(name, fields)
      # puts "==> collect_custom_fields_diff for #{name}, #{fields.size}" # DEBUG

      memo = initialize_custom_fields_diff(name)

      fields.map do |field|
        field.collect_diff(memo)
      end

      # collect fields with a modified localized field
      fields.each do |field|
        if field.localized_changed? && field.persisted?
          self._custom_field_localize_diff[name] << { field: field.name, localized: field.localized? }
        end
      end
    end

    # Apply the modifications collected from the custom fields by
    # updating all the documents of the relation.
    # The update uses the power of mongodb to make it fully optimized.
    #
    # @param [ String, Symbol ] name The name of the relation.
    #
    def apply_custom_fields_diff(name)
      # puts "==> apply_custom_fields_recipes for #{name}, #{self._custom_fields_diff[name].inspect}" # DEBUG

      operations = self._custom_fields_diff[name]
      operations['$set'].merge!({ 'custom_fields_recipe.version' => custom_fields_version(name) })
      collection = send(name).collection
      selector = send(name).criteria.selector

      # http://docs.mongodb.org/manual/reference/method/db.collection.update/#update-parameter
      # The <update> document must contain only update operator expressions.
      %w[set unset rename].each do |operation_name|
        _fields = operations.delete("$#{operation_name}")

        next if _fields.empty?

        _operation = { "$#{operation_name}" => _fields }
        collection.find(selector).update_many _operation
      end
    end

    # If the localized attribute has been changed in at least one of the custom fields,
    # we have to upgrade all the records enhanced by custom_fields in order to make
    # the values consistent with the mongoid localize option.
    #
    # Ex: post.attributes[:name] = 'Hello world' => post.attributes[:name] = { en: 'Hello world' }
    #
    # @param [ String, Symbol ] name The name of the relation.
    #
    def apply_custom_fields_localize_diff(name)
      return if self._custom_field_localize_diff[name].empty?

      send(name).all.each do |record|
        updates = {}

        # puts "[apply_custom_fields_localize_diff] processing: record #{record._id} / #{self._custom_field_localize_diff[name].inspect}" # DEBUG
        self._custom_field_localize_diff[name].each do |changes|
          value = record.attributes[changes[:field]]
          if changes[:localized]
            updates[changes[:field]] = { Mongoid::Fields::I18n.locale.to_s => value }
          else
            # the other way around
            next if value.nil?

            updates[changes[:field]] = value[Mongoid::Fields::I18n.locale.to_s]
          end
        end

        next if updates.empty?

        collection = send(name).collection
        collection.find(record.atomic_selector).update_one({ '$set' => updates })
      end
    end

    module ClassMethods
      # Determines if the relation is enhanced by the custom fields
      #
      # @example the Person class has somewhere in its code this: "custom_fields_for :addresses"
      #   Person.custom_fields_for?(:addresses)
      #
      # @param [ String, Symbol ] name The name of the relation.
      #
      # @return [ true, false ] True if enhanced, false if not.
      #
      def custom_fields_for?(name)
        _custom_fields_for.include?(name.to_s)
      end

      # Enhance a referenced collection OR the instance itself (by passing self) by providing methods to manage custom fields.
      #
      # @param [ String, Symbol ] name The name of the relation.
      #
      # @example
      #   class Company
      #     embeds_many :employees
      #     custom_fields_for :employees
      #   end
      #
      #   class Employee
      #     embedded_in :company, inverse_of: :employees
      #     field :name, String
      #   end
      #
      #   company.employees_custom_fields.build label: 'His/her position', name: 'position', kind: 'string'
      #   company.save
      #   company.employees.build name: 'Michael Scott', position: 'Regional manager'
      #
      def custom_fields_for(name)
        declare_embedded_in_definition_in_custom_field(name)

        # stores the relation name
        _custom_fields_for << name.to_s

        extend_for_custom_fields(name)
      end

      protected

      # Extends / Decorates the current class in order to be fully custom_fields compliant.
      # it declares news fields, adds new callbacks, ...etc
      #
      # @param [ String, Symbol ] name The name of the relation.
      #
      def extend_for_custom_fields(name)
        class_eval do
          field :"#{name}_custom_fields_version", type: ::Integer, default: 0

          embeds_many :"#{name}_custom_fields", class_name: dynamic_custom_field_class_name(name) # , cascade_callbacks: true # FIXME ?????

          accepts_nested_attributes_for :"#{name}_custom_fields", allow_destroy: true
        end

        class_eval <<-EOV, __FILE__, __LINE__ + 1
          after_initialize  :refresh_#{name}_metadata
          before_update     :bump_#{name}_custom_fields_version
          before_update     :collect_#{name}_custom_fields_diff
          after_update      :apply_#{name}_custom_fields_diff
          after_update      :apply_#{name}_custom_fields_localize_diff

          def ordered_#{name}_custom_fields
            self.ordered_custom_fields('#{name}')
          end

          protected

          def refresh_#{name}_metadata
            self.refresh_metadata_with_custom_fields('#{name}')
          end

          def bump_#{name}_custom_fields_version
            self.bump_custom_fields_version('#{name}')
          end

          def collect_#{name}_custom_fields_diff
            self.collect_custom_fields_diff(:#{name}, self.#{name}_custom_fields)
          end

          def apply_#{name}_custom_fields_diff
            self.apply_custom_fields_diff(:#{name})
          end

          def apply_#{name}_custom_fields_localize_diff
            self.apply_custom_fields_localize_diff(:#{name})
          end

        EOV
      end

      # Returns the class name of the custom field which is based both on the parent class name
      # and the name of the relation in order to avoid name conflicts (with other classes)
      #
      # @param [ Metadata ] metadata The relation's old metadata.
      #
      # @return [ String ] The class name
      #
      def dynamic_custom_field_class_name(name)
        "#{self.name}#{name.to_s.singularize.camelize}Field"
      end

      # An embedded relationship has to be defined on both side in order for it
      # to work properly. But because custom_field can be embedded in different
      # models that it's not aware of, we have to declare manually the definition
      # once we know the target class.
      #
      # @param [ String, Symbol ] name The name of the relation.
      #
      # @return [ Field ] The new field class.
      #
      def declare_embedded_in_definition_in_custom_field(name)
        klass_name = dynamic_custom_field_class_name(name).split('::').last # Use only the class, ignore the modules

        source = safe_module_parents.size > 1 ? safe_module_parents.first : Object

        return if source.const_defined?(klass_name)

        (klass = Class.new(::CustomFields::Field)).class_eval <<-EOF, __FILE__, __LINE__ + 1
            embedded_in :#{self.name.demodulize.underscore}, inverse_of: :#{name}_custom_fields, class_name: '#{self.name}'
        EOF

        source.const_set(klass_name, klass)
      end

      def safe_module_parents
        respond_to?(:module_parents) ? module_parents : parents
      end
    end
  end
end
