# encoding: utf-8
module Mongoid # :nodoc:
  module Relations #:nodoc:
    module Referenced #:nodoc:

      class In < Relations::One
        class << self
          def valid_options_with_parent_class
            valid_options_without_parent_class.push :custom_fields_parent_klass
          end
          alias_method_chain :valid_options, :parent_class
        end
      end
    end
  end
end
