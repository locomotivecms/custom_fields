module Mongoid #:nodoc

  # This module defines behaviour for fields.
  module Fields

    class I18n

      include Singleton

      attr_accessor :locale

      def self.locale
        self.instance.locale || ::I18n.locale
      end

      def self.locale=(value)
        self.instance.locale = value.to_sym rescue nil
      end

      def self.fallbacks
        if ::I18n.respond_to?(:fallbacks)
          ::I18n.fallbacks
        else
          nil
        end
      end

      def self.fallbacks?
        ::I18n.respond_to?(:fallbacks)
      end

      def self.with_locale(new_locale = nil)
        if tmp_locale
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