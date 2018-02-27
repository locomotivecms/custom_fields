# encoding: utf-8
module Mongoid
  class Criteria
    module Queryable

      # This is a smart hash for use with options and selectors.
      class Smash < Hash

        private

        # Get the localized value for the key if needed. If the field uses
        # localization the current locale will be appended to the key in
        # MongoDB dot notation.
        #
        # @api private
        #
        # @example Get the normalized key name.
        #   smash.localized_key("field", serializer)
        #
        # @param [ String ] name The name of the field.
        # @param [ Object ] serializer The optional field serializer.
        #
        # @return [ String ] The normalized key.
        #
        # @since 1.0.0
        def localized_key(name, serializer)
          serializer && serializer.localized? ? "#{name}.#{::Mongoid::Fields::I18n.locale}" : name
        end

      end

    end
  end
end
