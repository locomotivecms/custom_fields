class Employee

  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::TargetCustomFields

  field :full_name

  embedded_in :company, :inverse_of => :employees

end
