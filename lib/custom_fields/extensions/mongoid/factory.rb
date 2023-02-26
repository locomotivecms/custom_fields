# frozen_string_literal: true

module Mongoid # :nodoc:
  # Instantiates documents that came from the database.
  module Factory
    def from_db_with_custom_fields(klass, attributes = nil, criteria = nil, selected_fields = nil)
      klass.klass_with_custom_fields(attributes['custom_fields_recipe']) if klass.with_custom_fields?

      from_db_without_custom_fields(klass, attributes, criteria, selected_fields)
    end

    # equivalent for "alias_method_chain :from_db, :custom_fields"
    alias from_db_without_custom_fields from_db unless method_defined?(:from_db_without_custom_fields)
    alias from_db from_db_with_custom_fields
  end
end
