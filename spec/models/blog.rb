# frozen_string_literal: true

class Blog
  include Mongoid::Document
  include CustomFields::Source

  field :name

  has_many :people
  has_many :posts

  custom_fields_for :people
  custom_fields_for :posts
end