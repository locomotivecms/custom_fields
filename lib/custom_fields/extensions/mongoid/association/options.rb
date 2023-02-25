# encoding: utf-8

module CustomFieldsOptionsExtension
  def validate!
    option = @options.delete(:custom_fields_parent_klass)
    super.tap do
      @options[:custom_fields_parent_klass] = option if option
    end
  end
end

::Mongoid::Association::Relatable.send(:prepend, CustomFieldsOptionsExtension)


