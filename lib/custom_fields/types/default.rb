module CustomFields
  module Types
    module Default
      extend ActiveSupport::Concern

      module InstanceMethods

        def collect_default_diff(memo)
          if self.persisted?
            if self.destroyed?
              memo['$unset'][self.name] = 1
            elsif self.changed?
              if self.changes.key?(:name)
                old_name, new_name = self.changes[:name]
                memo['$rename'][old_name] = new_name
              end
            end
          else
            memo['$set'][self.name] = nil
          end

          (memo['$set']['custom_fields_recipe'] ||= []) << self.to_recipe
        end

      end

      module ClassMethods

      end
    end
  end
end