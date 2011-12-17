# encoding: utf-8
module Mongoid #:nodoc:

  # Instantiates documents that came from the database.
  module Factory

    def from_db_with_custom_fields(klass, attributes = {})
      if klass.with_custom_fields?
        klass.klass_with_custom_fields(attributes['custom_fields_recipe'])
      end
      from_db_without_custom_fields(klass, attributes)
    end

    # equivalent for "alias_method_chain :from_db, :custom_fields"
    alias_method :from_db_without_custom_fields, :from_db unless method_defined?(:from_db_without_custom_fields)
    alias_method :from_db, :from_db_with_custom_fields

  end

end