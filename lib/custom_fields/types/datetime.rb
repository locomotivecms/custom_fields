module CustomFields

  module Types

    module DateTime

      module Field; end

      module Target

        extend ActiveSupport::Concern

        module ClassMethods

          # Adds a datetime field
          #
          # @param [ Class ] klass The class to modify
          # @param [ Hash ] rule It contains the name of the field and if it is required or not
          #
          def apply_datetime_custom_field(klass, rule)
            name = rule['name']

            klass.field name, type: ::DateTime, localize: rule['localized'] || false

            # other methods
            klass.send(:define_method, :"formatted_#{name}") { _get_formatted_datetime(name) }
            klass.send(:define_method, :"formatted_#{name}=") { |value| _set_formatted_datetime(name, value) }

            if rule['required']
              klass.validates_presence_of name, :"formatted_#{name}"
            end
          end

          # Build a hash storing the formatted value for
          # a datetime custom field of an instance.
          #
          # @param [ Object ] instance An instance of the class enhanced by the custom_fields
          # @param [ String ] name The name of the datetime custom field
          #
          # @return [ Hash ] field name => formatted datetime
          #
          def datetime_attribute_get(instance, name)
            if value = instance.send(:"formatted_#{name}")
              { name => value, "formatted_#{name}" => value }
            else
              {}
            end
          end

          # Set the value for the instance and the datetime field specified by
          # the 2 params.
          #
          # @param [ Object ] instance An instance of the class enhanced by the custom_fields
          # @param [ String ] name The name of the datetime custom field
          # @param [ Hash ] attributes The attributes used to fetch the values
          #
          def datetime_attribute_set(instance, name, attributes)
            return unless attributes.key?(name) || attributes.key?("formatted_#{name}")

            value = attributes[name] || attributes["formatted_#{name}"]

            instance.send(:"formatted_#{name}=", value)
          end

        end

        protected

        def _set_formatted_datetime(name, value)
          if value.is_a?(::String) && !value.blank?
            datetime = ::DateTime._strptime(value, I18n.t('time.formats.default'))
 
            if datetime
              value = ::DateTime.new(datetime[:year], datetime[:mon], datetime[:mday], datetime[:hour], datetime[:min], datetime[:sec] || 0, datetime[:zone] || "")
            else
              value = ::DateTime.parse(value) rescue nil
            end
          end

          self.send(:"#{name}=", value)
        end

        def _get_formatted_datetime(name)
          self.send(name.to_sym).strftime(I18n.t('time.formats.default')) rescue nil
        end

      end

    end

  end

end
