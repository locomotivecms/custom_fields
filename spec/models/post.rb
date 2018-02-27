class Post

  include Mongoid::Document
  include CustomFields::Target

  field :title
  field :body

  belongs_to :blog, inverse_of: :posts, optional: true, custom_fields_parent_klass: true

  validates_presence_of :title, :body

end
