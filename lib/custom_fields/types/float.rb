module CustomFields
  module Types
    module Float

      module Field; end

      module Target
        extend ActiveSupport::Concern

        module ClassMethods

          # Add a string field
          #
          # @param [ Class ] klass The class to modify
          # @param [ Hash ] rule It contains the name of the field and if it is required or not
          #
          def apply_float_custom_field(klass, rule)
            klass.field rule['name'], type: ::Float, localize: rule['localized'] || false
            klass.validates_presence_of rule['name'] if rule['required']
            klass.validates rule['name'], numericality: true, if: ->(x){ rule['required'] }
          end

          # Build a hash storing the raw value for
          # a string custom field of an instance.
          #
          # @param [ Object ] instance An instance of the class enhanced by the custom_fields
          # @param [ String ] name The name of the string custom field
          #
          # @return [ Hash ] field name => raw value
          #
          def float_attribute_get(instance, name)
            self.default_attribute_get(instance, name)
          end

          # Set the value for the instance and the string field specified by
          # the 2 params.
          #
          # @param [ Object ] instance An instance of the class enhanced by the custom_fields
          # @param [ String ] name The name of the string custom field
          # @param [ Hash ] attributes The attributes used to fetch the values
          #
          def float_attribute_set(instance, name, attributes)
            self.default_attribute_set(instance, name, attributes)
          end

        end # ClassMethods

      end # Target

    end # Float
  end # Types
end # CustomFields
