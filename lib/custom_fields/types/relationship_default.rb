module CustomFields

  module Types

    module RelationshipDefault

      module Field

        extend ActiveSupport::Concern

        included do

          field :class_name
          field :inverse_of
          field :order_by

          validates_presence_of :class_name,                  :if => :is_relationship?
          validate              :ensure_class_name_security,  :if => :is_relationship?

          def is_relationship?
            method_name = :"#{self.type}_is_relationship?"
            self.respond_to?(method_name) && self.send(method_name)
          end

          protected

          def ensure_class_name_security
            true
            # FIXME: to be overridden in the target application
          end

        end

      end

    end

  end

end




