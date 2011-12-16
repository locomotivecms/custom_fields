# encoding: utf-8
module Mongoid #:nodoc:

  # Instantiates documents that came from the database.
  module Factory

    def from_db_with_custom_fields(klass, attributes = {})
      # puts "from_db.....#{klass.inspect}"

      if klass.methods.include?(:with_custom_fields?)
        # puts "klass with custom_fields"
        klass.ensure_klass_with_custom_fields(attributes['custom_fields_recipe'])
      end

      # super
      from_db_without_custom_fields(klass, attributes)
      # type = attributes["_type"]
      # if type.blank?
      #   klass.instantiate(attributes)
      # else
      #   type.camelize.constantize.instantiate(attributes)
      # end
    end

    # equivalent for "alias_method_chain :from_db, :custom_fields"
    alias_method :from_db_without_custom_fields, :from_db unless method_defined?(:from_db_without_custom_fields)
    alias_method :from_db, :from_db_with_custom_fields
  end

end