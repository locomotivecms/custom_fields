module CustomFields

  module Source

    extend ActiveSupport::Concern

    included do
      cattr_accessor :_custom_fields_for
      self._custom_fields_for = []

      attr_accessor :_custom_fields_diff
    end

    module InstanceMethods

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
        self.send(:"#{name}_custom_fields").sort { |a, b| (a.position || 0) <=> (b.position || 0) }
      end

      # Returns the recipe (meaning all the rules) needed to
      # build the custom klass
      #
      # @param [ String, Symbol ] name The name of the relation.
      #
      # @return [ Array ] An array of hashes
      #
      def custom_fields_recipe_for(name)
        self.ordered_custom_fields(name).map(&:to_recipe)
      end

      # Initializes the object tracking the modifications
      # of the custom fields
      #
      # @param [ String, Symbol ] name The name of the relation.
      #
      def initialize_custom_fields_diff(name)
        self._custom_fields_diff ||= {}
        self._custom_fields_diff[name] = { '$set' => {}, '$unset' => {}, '$rename' => {} }
      end

      # Tells if one or many custom fields got modified.
      #
      # @param [ String, Symbol ] name The name of the relation.
      #
      # @return [ Boolean ] True if they got modified
      #
      def custom_fields_changed?(name)
        self._custom_fields_diff[name] &&
        (!self._custom_fields_diff[name]['$set'].empty? ||
        !self._custom_fields_diff[name]['$unset'].empty? ||
        !self._custom_fields_diff[name]['$rename'].empty?)
      end

      # Collects all the modifications of the custom fields
      #
      # @param [ String, Symbol ] name The name of the relation.
      #
      # @return [ Array ] An array of hashes storing the modifications
      #
      def collect_custom_fields_diff(name, fields)
        # puts "==> collect_custom_fields_diff for #{name}, #{fields.size}" # DEBUG

        memo = self.initialize_custom_fields_diff(name)

        fields.map do |field|
          field.collect_diff(memo)
        end
      end

      # Apply the modifications collected from the custom fields by
      # updating all the documents of the relation.
      # The update uses the power of mongodb to make it fully optimized.
      #
      # @param [ String, Symbol ] name The name of the relation.
      #
      def apply_custom_fields_diff(name)
        # puts "==> apply_custom_fields_recipes for #{name}, #{fields.size}" # DEBUG

        return unless self.custom_fields_changed?(name) # no need to update them if no changes

        operations = self._custom_fields_diff[name]
        operations['$inc'] = { 'custom_fields_recipe.version' => 1 }
        collection, selector = self.send(name).collection, self.send(name).criteria.selector

        # puts "selector = #{selector.inspect}, memo = #{attributes.inspect}" # DEBUG

        collection.update selector, operations, :multi => true
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
        self._custom_fields_for.include?(name.to_s)
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
      #     embedded_in :company, :inverse_of => :employees
      #     field :name, String
      #   end
      #
      #   company.employees_custom_fields.build :label => 'His/her position', :name => 'position', :kind => 'string'
      #   company.save
      #   company.employees.build :name => 'Michael Scott', :position => 'Regional manager'
      #
      def custom_fields_for(name)
        self.declare_embedded_in_definition_in_custom_field(name)

        # stores the relation name
        self._custom_fields_for << name.to_s

        self.extend_for_custom_fields(name)
      end

      protected

      # Extends / Decorates the current class in order to be fully custom_fields compliant.
      # it declares news fields, adds new callbacks, ...etc
      #
      # @param [ String, Symbol ] name The name of the relation.
      #
      def extend_for_custom_fields(name)
        class_eval do
          embeds_many :"#{name}_custom_fields", :class_name => self.dynamic_custom_field_class_name(name) #, :cascade_callbacks => true # FIXME ?????

          accepts_nested_attributes_for :"#{name}_custom_fields", :allow_destroy => true
        end

        class_eval <<-EOV

          before_save       :collect_#{name}_custom_fields_diff
          after_save        :apply_#{name}_custom_fields_diff

          protected

          def collect_#{name}_custom_fields_diff
            self.collect_custom_fields_diff(:#{name}, self.#{name}_custom_fields)
          end

          def apply_#{name}_custom_fields_diff
            self.apply_custom_fields_diff(:#{name})
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
        klass_name = self.dynamic_custom_field_class_name(name).split('::').last # Use only the class, ignore the modules

        source = self.parents.size > 1 ? self.parents.first : Object

        unless source.const_defined?(klass_name)
          (klass = Class.new(::CustomFields::Field)).class_eval <<-EOF
            embedded_in :#{self.name.demodulize.underscore}, :inverse_of => :#{name}_custom_fields, :class_name => '#{self.name}'
          EOF

          source.const_set(klass_name, klass)
        end
      end

    end

  end

end