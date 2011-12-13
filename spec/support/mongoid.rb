require 'mongoid'

Mongoid.configure do |config|
  name = 'custom_fields_test'
  host = 'localhost'
  config.master = Mongo::Connection.new.db(name)
  config.master = Mongo::Connection.new('localhost', '27017', :logger => Logger.new($stdout)).db(name)
end

module Mongoid
  def self.reload_document(doc)
    if doc.embedded?
      parent = doc.class._parent

      parent = parent.class.find(parent._id)

      parent.send(doc.metadata.name).find(doc._id)
    else
      doc.class.find(doc._id)
    end
  end
end