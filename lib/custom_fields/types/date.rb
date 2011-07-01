module CustomFields
  module Types
    module Date

      extend ActiveSupport::Concern

      included do
        register_type :date, ::Date
      end

      module InstanceMethods

        def apply_date_type(klass)

          klass.class_eval <<-EOF

            def #{self.safe_alias}
              self.#{self._name}
            end

            def #{self.safe_alias}=(value)
              if value.is_a?(::String) && !value.blank?
                date = ::Date._strptime(value, I18n.t('date.formats.default'))
                value = ::Date.new(date[:year], date[:mon], date[:mday])
              end

              self.#{self._name} = value
            end

            def formatted_#{self.safe_alias}
              self.#{self._name}.strftime(I18n.t('date.formats.default')) rescue nil
            end

            alias formatted_#{self.safe_alias}= #{self.safe_alias}=
          EOF

          def add_date_validation(klass)
            if self.required?
              klass.validates_presence_of self.safe_alias.to_sym, :"formatted_#{self.safe_alias}"
            end
          end

        end

      end

    end
  end
end