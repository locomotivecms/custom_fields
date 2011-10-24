class ProductLine

  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::CustomFields
  include Mongoid::TargetCustomFields

  field :name
  field :description

  custom_fields_for :products

  scope :ordered, :order_by => [[:name, :asc]]

end
