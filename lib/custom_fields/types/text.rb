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
          apply_custom_field(name)
        end

      end

    end
  end
end