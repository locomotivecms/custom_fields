class Task

  include Mongoid::Document
  include Mongoid::Timestamps
  include CustomFields::ProxyClassEnabler

  field :title

  embedded_in :project, :inverse_of => :tasks

end