# frozen_string_literal: true

module CustomFieldsRelatableExtension
  def resolve_name(mod, name)
    super
  rescue NameError => e
    return name.constantize if name =~ CustomFields::KLASS_REGEXP

    raise e
  end

  def validate!
    option = @options.delete(:custom_fields_parent_klass)
    super.tap do
      @options[:custom_fields_parent_klass] = option if option
    end
  end
end

[
  Mongoid::Association::Embedded::EmbeddedIn,
  Mongoid::Association::Embedded::EmbedsMany,
  Mongoid::Association::Embedded::EmbedsOne,
  Mongoid::Association::Referenced::BelongsTo,
  Mongoid::Association::Referenced::HasMany,
  Mongoid::Association::Referenced::HasAndBelongsToMany,
  Mongoid::Association::Referenced::HasOne,
].each do |klass|
  klass.prepend CustomFieldsRelatableExtension
end
