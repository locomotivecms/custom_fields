module CustomFields
  module Types
    module Boolean

      extend ActiveSupport::Concern

      included do
        register_type :boolean, ::Boolean
      end

    end
  end
end