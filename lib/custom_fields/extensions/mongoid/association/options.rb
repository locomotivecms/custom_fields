# encoding: utf-8

module CustomFieldsOptionsExtension
  def validate!
    @options.delete(:custom_fields_parent_klass)
    super
  end
end

::Mongoid::Association::Relatable.send(:prepend, CustomFieldsOptionsExtension)


