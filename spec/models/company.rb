class Company

  include Mongoid::Document
  include Mongoid::Timestamps
  include CustomFields::ProxyClassEnabler
  include CustomFields::CustomFieldsFor

  field :name

  embeds_many :employees

  custom_fields_for :employees

  scope :ordered, :order_by => [[:name, :asc]]

end
