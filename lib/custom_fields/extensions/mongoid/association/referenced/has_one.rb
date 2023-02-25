# frozen_string_literal: true

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

::Mongoid::Association::Referenced::HasOne.prepend CustomFieldsInExtension
