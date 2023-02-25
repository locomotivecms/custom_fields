# frozen_string_literal: true

module CustomFieldsOptionsExtension
  def validate!
    option = @options.delete(:custom_fields_parent_klass)
    super.tap do
      @options[:custom_fields_parent_klass] = option if option
    end
  end
end

::Mongoid::Association::Relatable.prepend CustomFieldsOptionsExtension
