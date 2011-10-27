class Product

  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::CustomFields
  include Mongoid::TargetCustomFields

  field :name

  embedded_in :product_line
  custom_fields_for :product_line

end
