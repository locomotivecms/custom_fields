class Project

  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::CustomFields
  include Mongoid::TargetCustomFields

  field :name
  field :description

  references_many :people
  embeds_many :tasks

  custom_fields_for :people
  custom_fields_for :tasks

  custom_fields_for_itself

  scope :ordered, :order_by => [[:name, :asc]]

end
