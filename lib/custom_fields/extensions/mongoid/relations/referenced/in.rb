module Mongoid # :nodoc:
  module Relations #:nodoc:
    module Referenced #:nodoc:

      class In < Relations::One
        class << self
          def valid_options_with_parent_class
            valid_options_without_parent_class.push :custom_fields_parent_klass
          end

          alias_method :valid_options_without_parent_class, :valid_options
          alias_method :valid_options, :valid_options_with_parent_class

        end
      end
    end
  end
end
