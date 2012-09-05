module CustomFields

  module Types

    module Integer

      module Field; end

      module Target

        extend ActiveSupport::Concern

        module ClassMethods

          # Adds a Integer field
          #
          # @param [ Class ] klass The class to modify
          # @param [ Hash ] rule It contains the name of the field and if it is required or not
          #
          def apply_integer_custom_field(klass, rule)
            name = rule['name']

            klass.field name, :type => ::Integer, :localize => rule['localized'] || false
            klass.validates_numericality_of name, :only_integer => true
            if rule['required']
              klass.validates_presence_of name
            end
          end

        end

      end

    end

  end

end
