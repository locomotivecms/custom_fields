# encoding: utf-8

module CustomFieldsRelatableExtension
  def resolve_name(mod, name)
    begin
      super
    rescue NameError => exception
      return name.constantize if name =~ CustomFields::KLASS_REGEXP
      raise exception
    end
  end
end

::Mongoid::Association::Relatable.send(:prepend, CustomFieldsRelatableExtension)




