# frozen_string_literal: true

module CustomFieldsStringExtension
  def constantize
    super
  rescue NameError => e
    # DEBUG: puts "constantizing #{self.inspect}"
    # alright, does it look like a custom_fields dynamic klass ?
    if self =~ CustomFields::KLASS_REGEXP
      base = ::Regexp.last_match(1).constantize
      # we can know it for sure
      if base.with_custom_fields?
        relation = base.relations.values.detect do |association|
          association.options[:custom_fields_parent_klass] == true
        end

        # load the class which holds the recipe to build the dynamic klass
        if relation && parent_instance = relation.klass.find(::Regexp.last_match(2))
          # DEBUG: puts "re-building #{self}"
          return parent_instance.klass_with_custom_fields(relation.inverse_of)
        end
      end
    end
    # not a custom_fields dynamic klass or unable to re-build it
    raise e
  end
end

::String.prepend CustomFieldsStringExtension
