module CustomFields

  module Types

    module Date

      module Field; end

      module Target

        extend ActiveSupport::Concern

        module ClassMethods

          # Adds a date field
          #
          # @param [ Class ] klass The class to modify
          # @param [ Hash ] rule It contains the name of the field and if it is required or not
          #
          def apply_date_custom_field(klass, rule)
            name = rule['name']

            klass.field name, :type => ::Date, :localize => rule['localized'] || false

            # other methods
            klass.send(:define_method, :"formatted_#{name}") { _get_formatted_date(name) }
            klass.send(:define_method, :"formatted_#{name}=") { |value| _set_formatted_date(name, value) }

            if rule['required']
              klass.validates_presence_of name, :"formatted_#{name}"
            end
          end

        end

        protected

        def _set_formatted_date(name, value)
          if value.is_a?(::String) && !value.blank?
            date  = ::Date._strptime(value, I18n.t('date.formats.default'))
            value = ::Date.new(date[:year], date[:mon], date[:mday])
          end

          self.send(:"#{name}=", value)
        end

        def _get_formatted_date(name)
          self.send(name.to_sym).strftime(I18n.t('date.formats.default')) rescue nil
        end

      end

    end

  end

end