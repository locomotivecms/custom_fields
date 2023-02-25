# frozen_string_literal: true

# :nodoc

module Mongoid
  # This module defines behaviour for fields.
  module Fields
    class I18n
      attr_accessor :locale, :fallbacks

      def self.instance
        Thread.current[:mongoid_i18n] ||= Mongoid::Fields::I18n.new
      end

      def self.locale
        instance.locale || ::I18n.locale
      end

      def self.locale=(value)
        instance.locale = begin
          value.to_sym
        rescue StandardError
          nil
        end
      end

      def self.fallbacks
        if !instance.fallbacks.blank?
          instance.fallbacks
        elsif ::I18n.respond_to?(:fallbacks)
          ::I18n.fallbacks
        end
      end

      def self.fallbacks_for(locale, fallbacks)
        instance.fallbacks ||= {}
        instance.fallbacks[locale.to_sym] = fallbacks
      end

      def self.fallbacks?
        !instance.fallbacks.blank? || (::I18n.respond_to?(:fallbacks) && !::I18n.fallbacks.blank?)
      end

      def self.clear_fallbacks
        instance.fallbacks.try(:clear)
      end

      def self.with_locale(new_locale = nil)
        if new_locale
          current_locale  = locale
          self.locale     = new_locale
        end
        yield
      ensure
        self.locale = current_locale if new_locale
      end
    end
  end
end
