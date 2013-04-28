module CustomFields

  module Types

    module Text

      module Field

        extend ActiveSupport::Concern

        included do

          field :text_formatting, default: 'html'

        end

      end

      module Target

        extend ActiveSupport::Concern

        module ClassMethods

          # Adds a text field (simply a string field)
          #
          # @param [ Class ] klass The class to modify
          # @param [ Hash ] rule It contains the name of the field and if it is required or not
          #
          def apply_text_custom_field(klass, rule)
            apply_custom_field(klass, rule)
          end

          # Build a hash storing the raw value for
          # a string custom field of an instance.
          #
          # @param [ Object ] instance An instance of the class enhanced by the custom_fields
          # @param [ String ] name The name of the string custom field
          #
          # @return [ Hash ] field name => raw value
          #
          def text_attribute_get(instance, name)
            default_attribute_get(instance, name)
          end

          # Set the value for the instance and the text field specified by
          # the 2 params.
          #
          # @param [ Object ] instance An instance of the class enhanced by the custom_fields
          # @param [ String ] name The name of the text custom field
          # @param [ Hash ] attributes The attributes used to fetch the values
          #
          def text_attribute_set(instance, name, attributes)
            self.default_attribute_set(instance, name, attributes)
          end

        end

      end

    end

  end

end