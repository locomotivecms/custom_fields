module CustomFields

  module Types

    module Default

      module Field

        # Build the mongodb updates based on
        # the new state of the field
        #
        # @param [ Hash ] memo Store the updates
        #
        # @return [ Hash ] The memo object upgraded
        #
        def collect_default_diff(memo)
          # puts "collect_default_diff #{self.name}: #{self.persisted?} / #{self.destroyed?}" # DEBUG
          if self.persisted?
            if self.destroyed?
              memo['$unset'][self.name] = 1
            elsif self.changed?
              if self.changes.key?(:name)
                old_name, new_name = self.changes[:name]
                memo['$rename'][old_name] = new_name
              end
            end
          end

          (memo['$set']['custom_fields_recipe.rules'] ||= []) << self.to_recipe

          memo
        end

      end

      module Target

        extend ActiveSupport::Concern

        module ClassMethods

          # Modify the target class according to the rule.
          # By default, it declares the field and a validator
          # if specified by the rule
          #
          # @param [ Class ] klass The class to modify
          # @param [ Hash ] rule It contains the name of the field and if it is required or not
          #
          def apply_custom_field(klass, rule)
            klass.field rule['name'], :localize => rule['localized'] || false

            if rule['required']
              klass.validates_presence_of rule['name']
            end
          end

        end

      end

    end

  end

end