class Company

  include Mongoid::Document
  include Mongoid::Timestamps
  include CustomFields::ProxyClassEnabler
  include CustomFields::CustomFieldsFor

  field :name

  embeds_many :people

  custom_fields_for :people

  scope :ordered, :order_by => [[:name, :asc]]

end
