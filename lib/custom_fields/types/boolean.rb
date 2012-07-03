module CustomFields

  module Types

    module Boolean

      module Field; end

      module Target

        extend ActiveSupport::Concern

        module ClassMethods

          # Adds a boolean field
          #
          # @param [ Class ] klass The class to modify
          # @param [ Hash ] rule It contains the name of the field and if it is required or not
          #
          def apply_boolean_custom_field(klass, rule)
            klass.field rule['name'], :type => ::Boolean, :localize => rule['localized'] || false, :default => false

            if rule['required']
              klass.validates_presence_of rule['name']
            end
          end

        end

      end

    end

  end

end