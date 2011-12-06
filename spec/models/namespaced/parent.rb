module Namespaced
  class Parent

    include Mongoid::Document
    include Mongoid::Timestamps
    include Mongoid::CustomFields

    embeds_many :children, :class_name => 'Namespaced::Child'

    custom_fields_for :children

  end
end
