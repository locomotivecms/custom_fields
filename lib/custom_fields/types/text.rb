module CustomFields

  module Types

    module Text

      module Field

        extend ActiveSupport::Concern

        included do

          field :text_formatting, :default => 'html'

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

        end

      end

    end

  end

end