module Namespaced
  class Child

    include Mongoid::Document
    include Mongoid::Timestamps
    include Mongoid::TargetCustomFields

    embedded_in :parent, :inverse_of => :children, :class_name => 'Namespaced::Parent'

  end
end
