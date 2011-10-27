class Client

  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::CustomFields

  field :name

  embeds_many :locations

  custom_fields_for :locations

end