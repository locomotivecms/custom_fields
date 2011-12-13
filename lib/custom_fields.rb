$:.unshift File.expand_path(File.dirname(__FILE__))

require 'active_support'
require 'carrierwave/mongoid'

module CustomFields

  @@options = {
    :reserved_aliases => Mongoid.destructive_fields + %w(id _id send class)
  }

  def self.options=(options)
    @@options.merge!(options)
  end

  def self.options
    @@options
  end

end

require 'custom_fields/version'
require 'custom_fields/types/default'
require 'custom_fields/field'
require 'custom_fields/custom_fields_for'

# Load all the translation files
I18n.load_path += Dir[File.join(File.dirname(__FILE__), '..', 'config', 'locales', '*.yml')]

module Mongoid
  module CustomFields
    extend ActiveSupport::Concern
    included do
      include ::CustomFields::CustomFieldsFor
    end
  end

  # module TargetCustomFields
  #   extend ActiveSupport::Concern
  #   included do
  #     extend ::CustomFields::ProxyClass::Helper
  #     extend ::CustomFields::ProxyClass::Builder
  #   end
  # end
end



# ============= OLD =================

# require 'custom_fields/extensions/active_support'
# require 'custom_fields/extensions/mongoid/document'
# require 'custom_fields/extensions/mongoid/relations/accessors'
# require 'custom_fields/extensions/mongoid/relations/builders'
# require 'custom_fields/types/default'
# require 'custom_fields/types/string'
# require 'custom_fields/types/text'
# require 'custom_fields/types/category'
# require 'custom_fields/types/boolean'
# require 'custom_fields/types/date'
# require 'custom_fields/types/file'
# require 'custom_fields/types/has_one'
# require 'custom_fields/types/has_many/proxy_collection'
# require 'custom_fields/types/has_many/reverse_lookup_proxy_collection'
# require 'custom_fields/types/has_many'
# require 'custom_fields/proxy_class/base'
# require 'custom_fields/proxy_class/builder'
# require 'custom_fields/proxy_class/helper'

# require 'custom_fields/self_metadata'
# require 'custom_fields/custom_fields_for'




# module Mongoid
#   module CustomFields
#     extend ActiveSupport::Concern
#     included do
#       extend  ::CustomFields::ProxyClass::Helper
#       include ::CustomFields::CustomFieldsFor
#     end
#   end
#
#   module TargetCustomFields
#     extend ActiveSupport::Concern
#     included do
#       extend ::CustomFields::ProxyClass::Helper
#       extend ::CustomFields::ProxyClass::Builder
#     end
#   end
# end
#
# ActiveSupport::Inflector.inflections do |inflect|
#   inflect.irregular 'metadata', 'metadata'
# end
#
# # Load all the translation files
# I18n.load_path += Dir[File.join(File.dirname(__FILE__), '..', 'config', 'locales', '*.yml')]
#
# module MyBenchmark
#
#   def self.measure(caption, &block)
#     t1 = Time.now
#     returned_value = block.call
#     puts "[MyBenchmark] #{caption} took #{((Time.now - t1) * 1000).to_i} ms"
#     returned_value
#   end
#
# end