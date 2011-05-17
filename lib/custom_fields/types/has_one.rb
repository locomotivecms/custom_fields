module CustomFields
  module Types
    module HasOne

      extend ActiveSupport::Concern

      included do
        field :target
        # field :inverse_of

        validates_presence_of :target, :if => :has_one?
        # validate :inverse_of_must_be_unique

        # after_save :create_inverse_of_has_one
        # validates :validate_has_one

        register_type :has_one, BSON::ObjectId
      end

      module InstanceMethods

        # def validate_has_one
        #   if self.has_one?
        #     puts "[has_one] inverse_of #{self.inverse_of} / target = #{self.target}"
        #     self.errors.on(:target) if self.target.blank?
        #   end
        # end

        # def inverse_of_must_be_unique
        #   if self.has_one?
        #     puts "[has_one / #{self.object_id}] inverse_of #{self.inverse_of} / target = '#{self.target}'"
        #     target_klass = self.target.to_s.constantize
        #
        #     if target_klass.embedded?
        #       # self.errors.on(:target) if self.target.blank?
        #     else
        #
        #     end
        #   else
        #     true
        #   end
        # end

        # def create_inverse_of_has_one
        #   puts "[has_one / #{self.object_id}] inverse_of #{self.inverse_of} / target = '#{self.target}'"
        # end

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

              target_id = read_attribute(:#{self._name})
              target_klass = '#{self.target.to_s}'.constantize

              if target_klass.embedded?
                @_#{self._name} = target_klass._parent.send(target_klass.association_name).find(target_id)
              else
                @_#{self._name} = target_klass.find(target_id)
              end

              @_#{self._name}
            end
          EOF
        end

      end
    end
  end
end