module CustomFields
  module Types
    module Boolean

      extend ActiveSupport::Concern

      #
      # TODO
      #
      module TargetMethods

        def apply_boolean_custom_field(name, accessors_module)
          # puts "...define singleton methods :#{name} & :#{name}=" # DEBUG

          # # getter
          # define_singleton_method(name) { get_boolean(name) }
          #
          # # setter
          # define_singleton_method(:"#{name}=") { |value| set_boolean(name, value) }

          accessors_module.class_eval <<-EOV
            def #{name}
              get_boolean('#{name}')
            end

            def #{name}=(value)
              set_boolean('#{name}', value)
            end
          EOV
        end

        protected

        def get_boolean(name)
          self.boolean_serializer.deserialize(self.read_attribute(name.to_s))
        end

        def set_boolean(name, value)
          self.write_attribute(name.to_s, self.boolean_serializer.serialize(value))
        end

        #:nodoc:
        def boolean_serializer
          @boolean_serializer ||= Mongoid::Fields::Serializable::Boolean.new
        end

      end

    end
  end
end