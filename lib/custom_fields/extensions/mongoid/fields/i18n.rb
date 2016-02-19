module Mongoid #:nodoc

  # This module defines behaviour for fields.
  module Fields

    class I18n

      attr_accessor :locale, :fallbacks

      def self.instance
        Thread.current[:mongoid_i18n] ||= Mongoid::Fields::I18n.new
      end

      def self.locale
        self.instance.locale || ::I18n.locale
      end

      def self.locale=(value)
        self.instance.locale = value.to_sym rescue nil
      end

      def self.fallbacks
        if !self.instance.fallbacks.blank?
          self.instance.fallbacks
        elsif ::I18n.respond_to?(:fallbacks)
          ::I18n.fallbacks
        else
          nil
        end
      end

      def self.fallbacks_for(locale, fallbacks)
        self.instance.fallbacks ||= {}
        self.instance.fallbacks[locale.to_sym] = fallbacks
      end

      def self.fallbacks?
        !self.instance.fallbacks.blank? || (::I18n.respond_to?(:fallbacks) && !::I18n.fallbacks.blank?)
      end

      def self.clear_fallbacks
        self.instance.fallbacks.try(:clear)
      end

      def self.with_locale(new_locale = nil)
        if new_locale
          current_locale  = self.locale
          self.locale     = new_locale
        end
        yield
      ensure
        self.locale = current_locale if new_locale
      end

    end

  end

end
