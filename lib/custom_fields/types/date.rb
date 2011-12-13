module CustomFields
  module Types
    module Date
      extend ActiveSupport::Concern

      module TargetMethods

        def apply_date_custom_field(name)
          puts "...define singleton methods :#{name} / :formatted_#{name} & :#{name}= / :formatted_#{name}=" # DEBUG

          # getter
          define_singleton_method(name) { get_date(name) }
          define_singleton_method(:"formatted_#{name}") { get_formatted_date(name) }

          # setter
          define_singleton_method(:"#{name}=") { |value| set_date(name, value) }
          define_singleton_method(:"formatted_#{name}=") { |value| set_formatted_date(name, value) }
        end

        protected

        def get_date(name)
          Serializable.serialize(self.read_attribute(name.to_s))
        end

        def set_date(name, value)
          puts "set_date #{name} = #{value}" # DEBUG

          value = Serializable.serialize(value)

          self.write_attribute(name.to_s, value)
        end

        def set_formatted_date(name, value)
          if value.is_a?(::String) && !value.blank?
            date  = ::Date._strptime(value, I18n.t('date.formats.default'))
            value = ::Date.new(date[:year], date[:mon], date[:mday])
          end

          self.set_date(name, value)
        end

        def get_formatted_date(name)
          self.get_date(name).strftime(I18n.t('date.formats.default')) rescue nil
        end

      end

    end

    module Serializable

      extend Mongoid::Fields::Serializable::Timekeeping

      def self.deserialize(object)
       return nil if object.blank?
        if Mongoid::Config.use_utc?
          object.to_date
        else
          ::Date.new(object.year, object.month, object.day)
        end
      end

      protected

      def self.convert_to_time(value)
        value = ::Date.parse(value) if value.is_a?(::String)
        value = ::Date.civil(*value) if value.is_a?(::Array)
        ::Time.utc(value.year, value.month, value.day)
      end

    end
  end
end