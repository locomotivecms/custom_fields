# frozen_string_literal: true

module CustomFields
  module Types
    module Color
      module Field; end

      module Target
        extend ActiveSupport::Concern

        module ClassMethods
          # Add a color field
          #
          # @param [ Class ] klass The class to modify
          # @param [ Hash ] rule It contains the name of the field and if it is required or not
          #
          def apply_color_custom_field(klass, rule)
            apply_custom_field(klass, rule)
          end

          # Build a hash storing the raw value for
          # a color custom field of an instance.
          #
          # @param [ Object ] instance An instance of the class enhanced by the custom_fields
          # @param [ String ] name The name of the color custom field
          #
          # @return [ Hash ] field name => raw value
          #
          def color_attribute_get(instance, name)
            default_attribute_get(instance, name)
          end

          # Set the value for the instance and the color field specified by
          # the 2 params.
          #
          # @param [ Object ] instance An instance of the class enhanced by the custom_fields
          # @param [ String ] name The name of the color custom field
          # @param [ Hash ] attributes The attributes used to fetch the values
          #
          def color_attribute_set(instance, name, attributes)
            default_attribute_set(instance, name, attributes)
          end
        end
      end
    end
  end
end
