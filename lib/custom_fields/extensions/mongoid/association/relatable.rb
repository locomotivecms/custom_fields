# frozen_string_literal: true

module CustomFieldsRelatableExtension
  def resolve_name(mod, name)
    super
  rescue NameError => e
    return name.constantize if name =~ CustomFields::KLASS_REGEXP

    raise e
  end
end

::Mongoid::Association::Relatable.prepend CustomFieldsRelatableExtension
