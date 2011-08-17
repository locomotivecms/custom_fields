module CustomFields
  module Types
    module HasOne

      extend ActiveSupport::Concern

      included do
        field :target

        validates_presence_of :target, :if => :has_one?

        register_type :has_one, BSON::ObjectId
      end

      module InstanceMethods

        def apply_has_one_type(klass)
          klass.class_eval <<-EOF

            def #{self.safe_alias}=(id_or_object)
              if id_or_object.respond_to?(:_id)
                target_id = id_or_object._id
                 @_#{self._name} = id_or_object
              else
                target_id = id_or_object
                @_#{self._name} = nil # empty previous cached value
              end

              write_attribute(:#{self._name}, target_id)
            end

            def #{self.safe_alias}
              return @_#{self._name} unless @_#{self._name}.blank? # memoization

              target_id = self.send(:#{self._name})

              return nil if target_id.blank?

              target_klass = '#{self.target.to_s}'.constantize

              if target_klass.embedded?
                @_#{self._name} = target_klass._parent.reload.send(target_klass.association_name).find(target_id)
              else
                @_#{self._name} = target_klass.find(target_id)
              end

              @_#{self._name}
            rescue # target_klass does not exist anymore or the target element has been removed since
              nil
            end
          EOF
        end

      end
    end
  end
end