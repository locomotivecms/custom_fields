# frozen_string_literal: true

module CustomFields
  module Types
    module Integer
      module Field; end

      module Target
        extend ActiveSupport::Concern

        module ClassMethods
          # Add a integer field
          #
          # @param [ Class ] klass The class to modify
          # @param [ Hash ] rule It contains the name of the field and if it is required or not
          #
          def apply_integer_custom_field(klass, rule)
            name = rule['name']

            klass.field name, type: ::Integer, localize: rule['localized'] || false, default: rule['default']
            klass.validates_presence_of name if rule['required']
            klass.validates name, numericality: { only_integer: true }, if: ->(_x) { rule['required'] }
          end

          # Build a hash storing the raw value for
          # a string custom field of an instance.
          #
          # @param [ Object ] instance An instance of the class enhanced by the custom_fields
          # @param [ String ] name The name of the string custom field
          #
          # @return [ Hash ] field name => raw value
          #
          def integer_attribute_get(instance, name)
            default_attribute_get(instance, name)
          end

          # Set the value for the instance and the string field specified by
          # the 2 params.
          #
          # @param [ Object ] instance An instance of the class enhanced by the custom_fields
          # @param [ String ] name The name of the string custom field
          # @param [ Hash ] attributes The attributes used to fetch the values
          #
          def integer_attribute_set(instance, name, attributes)
            default_attribute_set(instance, name, attributes)
          end
        end
      end
    end
  end
end
