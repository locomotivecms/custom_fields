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

        def apply_text_custom_field(name, accessors_module)
          apply_custom_field(name, accessors_module)
        end

      end

    end
  end
end