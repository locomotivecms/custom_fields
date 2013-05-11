module CustomFields

  module Types

    module Default

      module Field

        # Build the mongodb updates based on
        # the new state of the field
        #
        # @param [ Hash ] memo Store the updates
        #
        # @return [ Hash ] The memo object upgraded
        #
        def collect_default_diff(memo)
          # puts "collect_default_diff #{self.name}: #{self.persisted?} / #{self.destroyed?}" # DEBUG
          if self.persisted?
            if self.destroyed?
              memo['$unset'][self.name] = 1
            elsif self.changed?
              if self.changes.key?('name')
                old_name, new_name = self.changes['name']
                memo['$rename'][old_name] = new_name
              end
            end
          end

          (memo['$set']['custom_fields_recipe.rules'] ||= []) << self.to_recipe

          memo
        end

      end

      module Target

        extend ActiveSupport::Concern

        module ClassMethods

          # Modify the target class according to the rule.
          # By default, it declares the field and a validator
          # if specified by the rule
          #
          # @param [ Class ] klass The class to modify
          # @param [ Hash ] rule It contains the name of the field and if it is required or not
          #
          def apply_custom_field(klass, rule)
            klass.field rule['name'], localize: rule['localized'] || false

            klass.validates_presence_of rule['name'] if rule['required']
            klass.validates_uniqueness_of rule['name'], scope: :_type if rule['unique']
          end

          # Build a hash storing the formatted (or not) values
          # for a custom field of an instance.
          # Since aliases are accepted, we return a hash. Beside,
          # it is more convenient to use (ex: API).
          # By default, it only returns hash with only one entry
          # whose key is the second parameter and the value the
          # value of the field in the instance given in first parameter.
          #
          # @param [ Object ] instance An instance of the class enhanced by the custom_fields
          # @param [ String ] name The name of the custom field
          #
          # @return [ Hash ] field name => formatted value or empty hash if no value
          #
          def default_attribute_get(instance, name)
            unless (value = instance.send(name.to_sym)).nil?
              { name => instance.send(name.to_sym) }
            else
              {}
            end
          end

          # Set the value for the instance and the field specified by
          # the 2 params.
          # Since the value can come from different attributes and other
          # params can modify the instance too, we need to pass a hash
          # instead of a single value.
          #
          # @param [ Object ] instance An instance of the class enhanced by the custom_fields
          # @param [ String ] name The name of the custom field
          # @param [ Hash ] attributes The attributes used to fetch the values
          #
          def default_attribute_set(instance, name, attributes)
            # do not go further if the name is not one of the attributes keys.
            return unless attributes.key?(name)

            # simple assign
            instance.send(:"#{name}=", attributes[name])
          end

        end

      end

    end

  end

end