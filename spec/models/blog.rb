class Blog

  include Mongoid::Document
  include Mongoid::CustomFields

  field :name

  has_many :posts

  custom_fields_for :posts

end