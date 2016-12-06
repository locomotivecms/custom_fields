module CustomFields

  module Types

    module Json

      module Field; end

      module Target

        extend ActiveSupport::Concern

        module ClassMethods

          # Adds a json field
          #
          # @param [ Class ] klass The class to modify
          # @param [ Hash ] rule It contains the name of the field and if it is required or not
          #
          def apply_json_custom_field(klass, rule)
            name = rule['name']

            klass.field name, type: Hash, localize: rule['localized'] || false
            klass.validates_presence_of name if rule['required']

            klass.before_validation { |record| record.send(:add_json_parsing_error, name) }

            klass.send(:define_method, :"#{name}=") do |json|
              super(decode_json(name, json))
            end
          end

          # Build a hash storing the formatted value for
          # a JSON custom field of an instance.
          #
          # @param [ Object ] instance An instance of the class enhanced by the custom_fields
          # @param [ String ] name The name of the json custom field
          #
          # @return [ Hash ] field name => JSON
          #
          def json_attribute_get(instance, name)
            self.default_attribute_get(instance, name)
          end

          # Set the value for the instance and the date field specified by
          # the 2 params.
          #
          # @param [ Object ] instance An instance of the class enhanced by the custom_fields
          # @param [ String ] name The name of the date custom field
          # @param [ Hash ] attributes The attributes used to fetch the values
          #
          def json_attribute_set(instance, name, attributes)
            self.default_attribute_set(instance, name, attributes)
          end

        end

        protected

        def decode_json(name, json)
          begin
            value = json.respond_to?(:to_str) ? ActiveSupport::JSON.decode(URI.unescape(json)) : json
            instance_variable_set(:"@#{name}_json_parsing_error", nil)
            value
          rescue ActiveSupport::JSON.parse_error
            instance_variable_set(:"@#{name}_json_parsing_error", $!.message)
            nil
          end
        end

        def add_json_parsing_error(name)
          error = instance_variable_get(:"@#{name}_json_parsing_error")

          if error
            msg = "Invalid #{name}: \"#{error}\". Check it out on http://jsonlint.com"
            self.errors.add(name, msg)
          end
        end

      end

    end

  end

end
