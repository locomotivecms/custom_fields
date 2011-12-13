class Blog

  include Mongoid::Document
  include CustomFields::Source

  field :name

  has_many :posts

  custom_fields_for :posts

end