# encoding: utf-8
module Mongoid #:nodoc:
  module Fields #:nodoc:
    module Internal #:nodoc:

      # Defines the behaviour for localized string fields.
      class Localized

        attr_accessor :original_field_type

        class << self

          # Instantiate 2 field types:
          # - a wrapper in charge of dealing with the translations
          # - the original field type to help to serialize / deserialize types
          #
          # @param [ Hash ] options The field options.
          #
          # @option options [ Class ] :type The class of the field.
          # @option options [ Object ] :default The default value for the field.
          # @option options [ String ] :label The field's label.
          #
          def instantiate_with_localize(name, options = {})
            instantiate_without_localize(name, options).tap do |field|
              field.original_field_type = Mappings.for(options[:type], options[:identity]).instantiate(name, options)
            end
          end

          alias_method_chain :instantiate, :localize

        end

        # Deserialize the object based on the current locale. Will look in the
        # hash for the current locale.
        #
        # @example Get the deserialized value.
        #   field.deserialize({ "en" => "testing" })
        #
        # @param [ Hash ] object The hash of translations.
        #
        # @return [ String ] The value for the current locale.
        #
        # @since 2.3.0
        def deserialize(object)
          return nil if object.nil?

          # puts "deserializing...#{locale.inspect} / #{object.inspect}" # DEBUG
          value = if !object.respond_to?(:keys) # if no translation hash is given, we return the object itself
            object
          elsif I18n.fallbacks?
            object[I18n.fallbacks[locale.to_sym].map(&:to_s).find { |loc| !object[loc].nil? }]
          else
            object[locale.to_s]
          end

          self.original_field_type.deserialize(value)
        end

        # Convert the provided string into a hash for the locale.
        #
        # @example Serialize the value.
        #   field.serialize("testing")
        #
        # @param [ String ] object The string to convert.
        #
        # @return [ Hash ] The locale with string translation.
        #
        # @since 2.3.0
        def serialize(object)
          # puts "serializing...#{locale} / #{object.inspect} / #{options.inspect}" # DEBUG

          value = self.original_field_type.serialize(object)

          { locale.to_s => value }
        end

        protected

        def locale
          I18n.locale
        end

      end
    end
  end
end
