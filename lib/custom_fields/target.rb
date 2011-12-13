module CustomFields

  module Target

    extend ActiveSupport::Concern

    included do
      field :custom_fields_recipe, :type => Array
    end

    module InstanceMethods

    end

    module ClassMethods

    end


  end

end