class Blog

  include Mongoid::Document
  include CustomFields::Source

  field :name

  has_many :posts
  # do
  #     def build(attributes = {}, options = {}, type = nil)
  #       super.tap do |doc|
  #         puts base.inspect
  #         puts doc.metadata.inspect
  #         puts doc.inspect
  #       end
  #     end
  #   end

  custom_fields_for :posts

end