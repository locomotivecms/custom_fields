module CustomFieldsManyExtension
  def build(attributes = {}, type = nil)
    if base.respond_to?(:custom_fields_for?) && base.custom_fields_for?(relation_metadata.name)
      # all the information about how to build the custom class are stored here
      recipe = base.custom_fields_recipe_for(relation_metadata.name)
      attributes ||= {}
      attributes.merge!(custom_fields_recipe: recipe)
      # build the class with custom_fields for the first time
      type = relation_metadata.klass.klass_with_custom_fields(recipe)
    end

    super(attributes, type)
  end
  alias :new :build
end

::Mongoid::Relations::Referenced::Many.send(:prepend, CustomFieldsManyExtension)
