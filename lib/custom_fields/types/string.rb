module CustomFields

  module Types

    module String

      module Field; end

      module Target

        extend ActiveSupport::Concern

        module ClassMethods

          # Adds a string field
          #
          # @param [ Class ] klass The class to modify
          # @param [ Hash ] rule It contains the name of the field and if it is required or not
          #
          def apply_string_custom_field(klass, rule)
            apply_custom_field(klass, rule)
          end

        end

      end

    end

  end

end