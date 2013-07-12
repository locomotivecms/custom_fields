$:.unshift File.expand_path(File.dirname(__FILE__))

require 'active_support'
require 'carrierwave/mongoid'
require 'money'

module CustomFields

  @@options = {
    reserved_names:     Mongoid.destructive_fields + %w(id _id send class),
    default_currency:   'EUR'
  }

  def self.options=(options)
    @@options.merge!(options)
  end

  def self.options
    @@options
  end

end

%w(  version
     extensions/active_support
     extensions/carrierwave
     extensions/mongoid/document
     extensions/mongoid/factory
     extensions/mongoid/relations/referenced/many
     extensions/mongoid/relations/referenced/in
     extensions/mongoid/fields.rb
     extensions/mongoid/fields/i18n.rb
     extensions/mongoid/fields/localized.rb
     types/default
     types/string
     types/text
     types/email
     types/date
     types/datetime
     types/boolean
     types/file
     types/select
     types/integer
     types/float
     types/money
     types/relationship_default
     types/belongs_to
     types/has_many
     types/many_to_many
     types/tags
     field
     source
     target_helpers
     target
    ).each do |lib|
      require_relative "./custom_fields/#{lib}"
    end

# Load all the translation files
I18n.load_path += Dir[File.join(File.dirname(__FILE__), '..', 'config', 'locales', '*.yml')]

module MyBenchmark

  def self.measure(caption, &block)
    t1 = Time.now
    returned_value = block.call
    puts "[MyBenchmark] #{caption} took #{((Time.now - t1) * 1000).to_i} ms"
    returned_value
  end

end
