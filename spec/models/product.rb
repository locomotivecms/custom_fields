class Product

  include Mongoid::Document
  include Mongoid::Timestamps
  include CustomFields::ProxyClassEnabler
  include CustomFields::CustomFieldsFor

  field :name

  embedded_in :product_line
  custom_fields_for :product_line

end
