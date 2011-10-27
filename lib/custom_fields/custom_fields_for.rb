module CustomFields

  module CustomFieldsFor

    extend ActiveSupport::Concern

    included do
      cattr_accessor :_custom_fields_for

      self._custom_fields_for = []
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

      # Returns the class enhanced by the custom fields defined in the parent class.
      #
      # @param [ String, Symbol ] name The name of the relation.
      #
      # @return [ Class ] The modified class.
      #
      def klass_with_custom_fields(name)
        self.class.klass_with_custom_fields(name, self)
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

      # Marks all the custom fields as persisted. Actually, this is a patch
      # for mongoid since for the update, it runs the reset_persisted_children method after
      # the callbacks unlike for the create.
      # We assume that all the fields have been validated in a previous step
      #
      # @param [ String, Symbol ] name The name of the relation.
      #
      def mark_custom_fields_as_persisted(name)
        self.send(:"#{name}_custom_fields").each do |field|
          field.instance_variable_set(:@new_record, false) unless field.persisted?
        end
      end

      # Builds the class enhanced by the custom fields defined in the parent class.
      # The new class inherits from the original one.
      #
      # @param [ String, Symbol ] name The name of the relation.
      # @param [ Metadata ] metadata The relation's metadata.
      #
      # @return [ Class ] The modified class.
      #
      def build_klass_with_custom_fields(name, metadata)
        custom_fields = self.ordered_custom_fields(name)

        metadata.klass.to_klass_with_custom_fields(name, self, custom_fields)
      end

      # Marks the class enhanced by the custom fields as invalidated
      #
      # @param [ String, Symbol ] name The name of the relation.
      #
      def mark_klass_with_custom_fields_as_invalidated(name)
        self.send(:"invalidate_#{name}_klass_flag=", true)
      end

      # Reset the flag telling if the class enhanced by the custom fields is invalidated
      #
      # @param [ String, Symbol ] name The name of the relation.
      #
      def reset_klass_with_custom_fields_invalidated_flag(name)
        # puts "* reset_klass_with_custom_fields_invalidated_flag #{name}"
        self.send(:"invalidate_#{name}_klass_flag=", false)
      end

      # Determines if the enhanced class has to be invalidated.
      #
      # @param [ String, Symbol ] name The name of the relation.
      #
      # @return [ true, false ] True if enhanced, false if not.
      #
      def invalidate_klass_with_custom_fields?(name)
        !!self.send(:"invalidate_#{name}_klass_flag")
      end

      # Destroy the class enhanced by the custom fields so that next time we need it,
      # we have a fresh new one.
      #
      # @param [ String, Symbol ] name The name of the relation.
      #
      def invalidate_klass_with_custom_fields(name)
        self.class.invalidate_klass_with_custom_fields(name, self)
      end

      # Duplicates a metadata and assigns the enhanced class to it.
      #
      # @param [ Metadata ] metadata The relation's old metadata.
      #
      # @return [ Metadata ] The relation's new metadata
      #
      def clone_metadata_for_custom_fields(metadata)
        puts "-> clone_metadata_for_custom_fields #{metadata.name}"

        klass = self.build_klass_with_custom_fields(metadata.name, metadata)

        # we do not want that other instances of the parent class have the same metadata
        metadata.clone.tap do |metadata|
          metadata.instance_variable_set(:@klass, klass)
        end
      end

      # When the fields have been modified and before the object is saved,
      # we bump the version.
      #
      # @param [ String, Symbol ] name The name of the relation.
      #
      def bump_custom_fields_version(name)
        if self.invalidate_klass_with_custom_fields?(name)
          # puts "%%% bump_custom_fields_version #{name} #{self.send(:"#{name}_custom_fields_version").inspect}"
          version = self.send(:"#{name}_custom_fields_version") || 0
          self.send(:"#{name}_custom_fields_version=", version + 1)
        end
      end

      # Increments by 1 the counter couting the number of added custom fields
      # for a relation
      #
      # @param [ String, Symbol ] name The name of the relation.
      #
      # @return [ Integer ] The new value of the counter
      #
      def bump_custom_fields_counter(name)
        counter = self.send(:"#{name}_custom_fields_counter") || 0
        self.send(:"#{name}_custom_fields_counter=", counter + 1)
      end

      # Builds a new relation so that the builder takes the last version of
      # the enhanced class when creating new instances
      #
      # @param [ String, Symbol ] name The name of the relation.
      #
      def rebuild_custom_fields_relation(name)
        # metadata = self.clone_metadata_for_custom_fields(self.relations[name.to_s])

        puts "rebuild_custom_fields_relation #{name}"

        metadata = self.relations[name.to_s]
        self.build(name, nil, metadata)
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

      # Enhance an embedded collection OR the instance itself (by passing self) by providing methods to manage custom fields.
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
      #   company.employees_custom_fields.build :label => 'His/her position', :_alias => 'position', :kind => 'string'
      #   company.employees.build :name => 'Michael Scott', :position => 'Regional manager'
      #
      def custom_fields_for(name)
        self.declare_embedded_in_definition_in_custom_field(name)

        # stores the relation name
        self._custom_fields_for << name.to_s

        self.extend_for_custom_fields(name)
      end

      # Enhances the class itself
      #
      # @example
      #   class Company
      #     custom_fields_for_itself
      #   end
      #
      #   company.self_metadata_custom_fields.build :label => 'Shipping Address', :_alias => 'address', :kind => 'text'
      #   company.self_metadata.address = '700 S Laflin, 60607 Chicago'
      #   other_company.self_metadata.address # returns a "not defined method" error
      #
      def custom_fields_for_itself
        self.embeds_one :self_metadata, :class_name => '::CustomFields::SelfMetadata'

        class_eval do
          def self_metadata_with_automatic_build
            object = self_metadata_without_automatic_build
            object || self.build_self_metadata
          end
          alias_method_chain :self_metadata, :automatic_build
        end

        self.custom_fields_for('self_metadata')
      end

      protected

      # Extends / Decorates the current class in order to be fully custom_fields compliant.
      # it declares news fields, adds new callbacks, ...etc
      #
      # @param [ String, Symbol ] name The name of the relation.
      #
      def extend_for_custom_fields(name)
        class_eval do
          field :"#{name}_custom_fields_counter", :type => Integer, :default => 0
          field :"#{name}_custom_fields_version", :type => Integer, :default => 0

          embeds_many :"#{name}_custom_fields", :class_name => self.dynamic_custom_field_class_name(name), :cascade_callbacks => true

          attr_accessor :"invalidate_#{name}_klass_flag" # flag for invalidating the custom class

          accepts_nested_attributes_for :"#{name}_custom_fields", :allow_destroy => true
        end

        class_eval <<-EOV

          before_validation { |r| puts "--> BEFORE VALIDATION (#{name}) / " + r.#{name}_klass.inspect  }
          before_save   :bump_#{name}_custom_fields_version
          after_save    :mark_#{name}_custom_fields_as_persisted
          after_save    :rebuild_#{name}_relation
          after_save    :reset_#{name}_klass_invalidated_flag
          after_destroy :invalidate_#{name}_klass

          def #{name}_klass
            self.klass_with_custom_fields('#{name}')
          end

          def #{name}_klass_name
            self.class.klass_name_with_custom_fields('#{name}', self)
          end

          def #{name}_klass_out_of_date?
            self.#{name}_klass.nil? || self.#{name}_klass.version != self.#{name}_custom_fields_version
          end

          def invalidate_#{name}_klass
            self.invalidate_klass_with_custom_fields('#{name}')
          end

          def invalidate_#{name}_klass?
            self.invalidate_klass_with_custom_fields?('#{name}')
          end

          def rebuild_#{name}_relation
            puts "--> AFTER SAVE (#{name})"
            if self.#{name}_klass_out_of_date?
              puts 'rebuild relation for #{name} after save'
              self.rebuild_custom_fields_relation('#{name}')
            end
          end

          protected

          def bump_#{name}_custom_fields_version
            puts "--> BEFORE SAVE (#{name})"
            self.bump_custom_fields_version('#{name}')
          end

          def mark_#{name}_custom_fields_as_persisted
            self.mark_custom_fields_as_persisted('#{name}')
          end

          def reset_#{name}_klass_invalidated_flag
            self.reset_klass_with_custom_fields_invalidated_flag('#{name}')
          end

        EOV

        # # mongoid tiny patch: for performance optimization (ie: we do want to invalidate klass with custom fields every time we save a field)
        # unless instance_methods.collect(&:to_s).include?('write_attributes_with_custom_fields')
        #   class_eval do
        #     def write_attributes_with_custom_fields(attrs = nil, guard_protected_attributes = true)
        #       self.instance_variable_set(:@_writing_attributes_with_custom_fields, true)
        #       self.write_attributes_without_custom_fields(attrs, guard_protected_attributes)
        #     end
        #     alias_method_chain :write_attributes, :custom_fields
        #   end
        # end
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
        klass_name = self.dynamic_custom_field_class_name(name)

        unless Object.const_defined?(klass_name)
          (klass = Class.new(::CustomFields::Field)).class_eval <<-EOF
            embedded_in :#{self.name.underscore}, :inverse_of => :#{name}_custom_fields
          EOF

          Object.const_set(klass_name, klass)
        end
      end

    end

  end

end


