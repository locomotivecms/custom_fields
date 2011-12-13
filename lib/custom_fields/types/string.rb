module CustomFields
  module Types
    module String
      extend ActiveSupport::Concern

      module TargetMethods

        def apply_string_custom_field(name)
          # puts "...define singleton methods :#{name} & :#{name}=" # DEBUG

          # getter
          define_singleton_method(name) { get_string(name) }

          # setter
          define_singleton_method(:"#{name}=") { |value| set_string(name, value) }
        end

        protected

        def get_string(name)
          self.read_attribute(name.to_s)
        end

        def set_string(name, value)
          self.write_attribute(name.to_s, value)
        end

      end

    end
  end
end