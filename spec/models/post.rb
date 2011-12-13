class Post

  include Mongoid::Document
  include CustomFields::Target

  field :title
  field :body

  belongs_to :blog

  # after_initialize :foo
  #
  # def foo
  #   "YEEAAAAH FOOO !"
  # end

end