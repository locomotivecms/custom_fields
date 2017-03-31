module CustomFieldsInExtension
  module ClassMethods
    def valid_options
      [:custom_fields_parent_klass] + super
    end
  end

  def self.prepended(base)
    class << base
      prepend ClassMethods
    end
  end
end

::Mongoid::Relations::Referenced::In.send(:prepend, CustomFieldsInExtension)
