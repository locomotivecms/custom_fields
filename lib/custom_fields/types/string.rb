module CustomFields
  module Types
    module String

      extend ActiveSupport::Concern

      #
      # TODO
      #
      module TargetMethods

        def apply_string_custom_field(name)
          apply_custom_field(name)
        end

      end

    end
  end
end