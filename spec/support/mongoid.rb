require 'mongoid'

Mongoid.configure do |config|
  name = 'custom_fields_test'
  config.connect_to name
end

# Mongoid.logger = Logger.new($stdout)
# Mongoid.logger.level = Logger::DEBUG
Mongoid.logger.level = Logger::INFO
Mongo::Logger.logger.level = Logger::INFO

module Mongoid
  def self.reload_document(doc)
    if doc.embedded?
      parent = doc.class._parent
      parent = parent.class.find(parent._id)
      parent.send(doc.relation_metadata.name).find(doc._id)
    else
      doc.class.find(doc._id)
    end
  end
end
