class Post

  include Mongoid::Document
  include CustomFields::Target

  field :title
  field :body

  belongs_to :blog

end