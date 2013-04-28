# encoding: utf-8
module Mongoid # :nodoc:
  module Relations #:nodoc:
    module Referenced #:nodoc:

      class In < Relations::One

        class << self

          def valid_options
            [:autosave, :foreign_key, :index, :polymorphic, :custom_fields_parent_klass]
          end

        end

      end

    end
  end
end
