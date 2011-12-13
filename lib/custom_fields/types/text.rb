module CustomFields
  module Types
    module Text

      extend ActiveSupport::Concern

      included do
        field :text_formatting, :default => 'html'
      end

      #
      # TODO
      #
      module TargetMethods

        def apply_text_custom_field(name)
          # puts "...define singleton methods :#{name} & :#{name}=" # DEBUG

          # getter
          define_singleton_method(name) { get_text(name) }

          # setter
          define_singleton_method(:"#{name}=") { |value| set_text(name, value) }
        end

        protected

        def get_text(name)
          self.read_attribute(name.to_s)
        end

        def set_text(name, value)
          self.write_attribute(name.to_s, value)
        end

      end

    end
  end
end