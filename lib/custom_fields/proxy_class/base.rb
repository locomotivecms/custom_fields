module CustomFields
  module ProxyClass

    module Base

      extend ActiveSupport::Concern

      included do
        cattr_accessor :custom_fields, :_parent, :association_name, :built_at, :version
      end

      module InstanceMethods

        # Returns the list of the custom fields used to build this class
        #
        # @return [ List ] the list of custom fields
        #
        def custom_fields
          self.class.custom_fields
        end

        # Returns the fields specified by the custom fields and their values
        #
        # @return [ Hash ] the hash
        #
        def aliased_attributes
          hash = { :created_at => self.created_at, :updated_at => self.updated_at } rescue {}

          (self.custom_fields || []).each do |field|
            case field.kind
            when 'file' then hash[field._alias] = self.send(field._name.to_sym).url
            else
              hash[field._alias] = self.send(field._name.to_sym)
            end
          end

          hash
        end

      end

      module ClassMethods

        # Returns the fields specified by the custom fields and their values
        #
        def model_name
          @_model_name ||= ActiveModel::Name.new(self.superclass)
        end

        # Declares a field within the class based on the information given by the custom field
        #
        # @param [ Field ] field The custom field
        #
        def apply_custom_field(field)
          puts "field #{field._name} persisted? #{field.persisted?} / valid ? #{field.quick_valid?}"
          return if !field.persisted? || !field.quick_valid?

          self.custom_fields ||= []

           if self.lookup_custom_field(field._name).nil?
             self.custom_fields << field
             field.apply(self)
           end
        end

        # Determines if the class has already declared the field
        #
        # @param [ String ] name The name of the custom field
        #
        # @return [ true, false ] True if found it, false if not.
        #
        def lookup_custom_field(name)
          self.custom_fields.detect { |f| f._name == name }
        end

        # Convenient method to get the name of a custom field from its alias
        #
        # @param [ String ] value The _alias value of the custom field
        #
        # @return [ String ] The name of the custom field.
        #
        def custom_field_alias_to_name(value)
          self.custom_fields.detect { |f| f._alias == value }._name
        end

        # Convenient method to get the _alias of a custom field from its name
        #
        # @param [ String ] value The name value of the custom field
        #
        # @return [ String ] The _alias of the custom field.
        #
        def custom_field_name_to_alias(value)
          self.custom_fields.detect { |f| f._name == value }._alias
        end

        # Tells Mongoid that this class is a child of a super class (even if it is no true)
        #
        def hereditary?
          false
        end

      end

    end

  end
end





