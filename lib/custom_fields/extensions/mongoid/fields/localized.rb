# frozen_string_literal: true

module Mongoid # :nodoc:
  module Fields # :nodoc:
    # The behaviour of the Localized fields in the custom fields gem is different
    # because we do not rely on I18n directly but on a slight version Mongoid::Fields::I18n.
    # The main reason is only practical to handle the following case:
    # -> Back-office in English and editing content in French.
    #
    # TODO: use this gem instead https://github.com/simi/mongoid-localizer
    #
    class Localized < Standard
      def mongoize(object)
        { locale.to_s => type.mongoize(object) }
      end

      private

      def lookup(object)
        value = if object.key?(locale.to_s)
                  object[locale.to_s]
                elsif object.key?(locale)
                  object[locale]
                end
        return value unless value.nil?

        return unless fallbacks? && i18n.respond_to?(:fallbacks)

        fallback_key = i18n.fallbacks[locale].find do |loc|
          object.key?(loc.to_s) || object.key?(loc)
        end
        object[fallback_key.to_s] || object[fallback_key]
      end

      # def lookup(object)
      #   if !object.respond_to?(:keys) # if no translation hash is given, we return the object itself
      #     object
      #   elsif object.has_key?(locale.to_s)
      #     object[locale.to_s]
      #   elsif I18n.fallbacks?
      #     lookup_with_fallback(object)
      #   else
      #     nil
      #   end
      # end

      # def lookup_with_fallback(object)
      #   fallback_locales = I18n.fallbacks[locale].try(:map, &:to_s)

      #   if fallback_locales
      #     _locale = fallback_locales.find { |loc| !object[loc].nil? }
      #     object[_locale]
      #   else
      #     nil
      #   end
      # end

      def locale
        # be careful, it does not return ::I18n.locale
        i18n.locale
      end

      def i18n
        ::Mongoid::Fields::I18n
      end
    end
  end
end
