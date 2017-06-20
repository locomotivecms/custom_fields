module CustomFields
  module Types
    module Password

      module Field

        MIN_PASSWORD_LENGTH = 6

      end

      module Target
        extend ActiveSupport::Concern

        module ClassMethods

          # Add a password field
          #
          # @param [ Class ] klass The class to modify
          # @param [ Hash ] rule It contains the name of the field and if it is required or not
          #
          def apply_password_custom_field(klass, rule)
            label, name = rule['label'], rule['name']

            klass.field :"#{name}_hash"

            klass.send(:define_method, name.to_sym) { '' }
            klass.send(:define_method, :"#{name}=") { |value| _encrypt_password(name, value) }
            klass.send(:define_method, :"#{name}_confirmation") { '' }
            klass.send(:define_method, :"#{name}_confirmation=") { |value| _set_confirmation_password(name, value) }

            klass.validate { _check_password(label, name) }
          end

          # Build a hash storing the raw value for
          # a string custom field of an instance.
          #
          # @param [ Object ] instance An instance of the class enhanced by the custom_fields
          # @param [ String ] name The name of the string custom field
          #
          # @return [ Hash ] field name => raw value
          #
          def password_attribute_get(instance, name)
            {}
          end

          # Set the value for the instance and the string field specified by
          # the 2 params.
          #
          # @param [ Object ] instance An instance of the class enhanced by the custom_fields
          # @param [ String ] name The name of the string custom field
          # @param [ Hash ] attributes The attributes used to fetch the values
          #
          def password_attribute_set(instance, name, attributes)
            instance._encrypt_password(name, attributes[name])
          end

        end # ClassMethods

        def _set_confirmation_password(name, confirmation)
          self.instance_variable_set(:"@#{name}_confirmation", confirmation)
        end

        def _encrypt_password(name, new_password)
          return if new_password.blank?

          self.instance_variable_set(:"@#{name}", new_password)

          self.send(:"#{name}_hash=", BCrypt::Password.create(new_password))
        end

        def _check_password(label, name)
          new_password = self.instance_variable_get(:"@#{name}")
          confirmation = self.instance_variable_get(:"@#{name}_confirmation")

          return if new_password.blank?

          if new_password.size < CustomFields::Types::Password::Field::MIN_PASSWORD_LENGTH
            self.errors.add(name, :too_short, count: CustomFields::Types::Password::Field::MIN_PASSWORD_LENGTH)
          end

          if confirmation && confirmation != new_password
            self.errors.add("#{name}_confirmation", :confirmation, attribute: label || name)
          end
        end

      end # Target

    end # Password
  end # Types
end # CustomFields
