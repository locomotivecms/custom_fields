# frozen_string_literal: true

require 'English'
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
            default_attribute_get(instance, name)
          end

          # Set the value for the instance and the date field specified by
          # the 2 params.
          #
          # @param [ Object ] instance An instance of the class enhanced by the custom_fields
          # @param [ String ] name The name of the date custom field
          # @param [ Hash ] attributes The attributes used to fetch the values
          #
          def json_attribute_set(instance, name, attributes)
            default_attribute_set(instance, name, attributes)
          end
        end

        protected

        def decode_json(name, json)
          value = json.respond_to?(:to_str) && !json.blank? ? ActiveSupport::JSON.decode(URI.decode_www_form_component(json)) : json
          value = nil if json.blank?

          # Only hashes are accepted
          raise ActiveSupport::JSON.parse_error, 'Only a Hash object is accepted' if value && !value.is_a?(Hash)

          instance_variable_set(:"@#{name}_json_parsing_error", nil)
          value
        rescue ActiveSupport::JSON.parse_error
          instance_variable_set(:"@#{name}_json_parsing_error", $ERROR_INFO.message)
          nil
        end

        def add_json_parsing_error(name)
          error = instance_variable_get(:"@#{name}_json_parsing_error")

          return unless error

          msg = "Invalid #{name}: \"#{error}\". Check it out on http://jsonlint.com"
          errors.add(name, msg)
        end
      end
    end
  end
end
