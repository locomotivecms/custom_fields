class Person

  include Mongoid::Document
  include Mongoid::Timestamps
  include CustomFields::ProxyClassEnabler

  field :full_name

  referenced_in :project, :inverse_of => :people

end