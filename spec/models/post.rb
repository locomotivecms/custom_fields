class Post

  include Mongoid::Document
  include CustomFields::Target

  field :title
  field :body

  belongs_to :blog

  validates_presence_of :title, :body

end
