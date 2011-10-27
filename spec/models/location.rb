class Location

  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::TargetCustomFields

  field :name

  embedded_in :project, :inverse_of => :locations

end