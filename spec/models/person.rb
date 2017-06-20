class Person

  include Mongoid::Document
  include CustomFields::Target

  field :name

  belongs_to :blog

end
