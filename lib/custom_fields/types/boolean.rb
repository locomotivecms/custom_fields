module CustomFields

  module Types

    module Boolean

      module Field; end

      module Target

        extend ActiveSupport::Concern

        module ClassMethods

          # Adds a boolean field. It can not be required.
          #
          # @param [ Class ] klass The class to modify
          # @param [ Hash ] rule It contains the name of the field.
          #
          def apply_boolean_custom_field(klass, rule)
            klass.field rule['name'], type: ::Boolean, localize: rule['localized'] || false, default: false
          end

          # Build a hash storing the boolean value (true / false) for
          # a boolean custom field of an instance.
          #
          # @param [ Object ] instance An instance of the class enhanced by the custom_fields
          # @param [ String ] name The name of the boolean custom field
          #
          # @return [ Hash ] field name => true / false
          #
          def boolean_attribute_get(instance, name)
            default_attribute_get(instance, name)
          end

          # Set the value for the instance and the boolean field specified by
          # the 2 params.
          #
          # @param [ Object ] instance An instance of the class enhanced by the custom_fields
          # @param [ String ] name The name of the boolean custom field
          # @param [ Hash ] attributes The attributes used to fetch the values
          #
          def boolean_attribute_set(instance, name, attributes)
            self.default_attribute_set(instance, name, attributes)
          end

        end

      end

    end

  end

end