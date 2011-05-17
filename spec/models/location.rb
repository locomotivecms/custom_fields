class Location

  include Mongoid::Document
  include Mongoid::Timestamps
  include CustomFields::ProxyClassEnabler

  field :name

  embedded_in :project, :inverse_of => :locations

end