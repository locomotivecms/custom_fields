# encoding: utf-8
module Mongoid #:nodoc:

  # Instantiates documents that came from the database.
  module Factory

    def from_db(klass, attributes = {})
      if klass.methods.include?(:with_custom_fields)
        puts "klass with custom_fields"
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

    alias_method_chain :from_db, :custom_fields

  end

end