module CustomFields
  module Types
    module Default

      extend ActiveSupport::Concern

      module InstanceMethods

        #
        # TODO
        #
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

      module TargetMethods

        protected

        def apply_custom_field(name)
          # puts "...define singleton methods :#{name} & :#{name}=" # DEBUG

          # getter
          define_singleton_method(name) do
            read_attribute(name.to_s)
          end

          # setter
          define_singleton_method(:"#{name}=") do |value|
            write_attribute(name.to_s, value)
          end
        end

      end

    end
  end
end