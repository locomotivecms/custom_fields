class Person

  include Mongoid::Document
  include CustomFields::Target

  # custom_fields_parent_klass 'Blog'

  field :name

  belongs_to :blog

end
