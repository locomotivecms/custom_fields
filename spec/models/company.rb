class Company

  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::CustomFields

  field :name

  embeds_many :employees

  custom_fields_for :employees

  scope :ordered, :order_by => [[:name, :asc]]

end
