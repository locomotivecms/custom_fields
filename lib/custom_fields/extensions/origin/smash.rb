# encoding: utf-8
module Origin

  # This is a smart hash for use with options and selectors.
  class Smash < Hash

    private

    # Get the normalized value for the key. If localization is in play the
    # current locale will be appended to the key in MongoDB dot notation.
    #
    # FIXME (Did).
    # This version DOES NOT USE ::I18n.locale directly.
    # See the localized.rb file for more explanation.
    #
    # @api private
    #
    # @example Get the normalized key name.
    #   smash.normalized_key("field", serializer)
    #
    # @param [ String ] name The name of the field.
    # @param [ Object ] serializer The optional field serializer.
    #
    # @return [ String ] The normalized key.
    #
    # @since 1.0.0
    def normalized_key(name, serializer)
      # serializer && serializer.localized? ? "#{name}.#{::I18n.locale}" : name
      serializer && serializer.localized? ? "#{name}.#{::Mongoid::Fields::I18n.locale}" : name
    end

  end
end