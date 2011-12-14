module CustomFields
  module Types
    module Date

      extend ActiveSupport::Concern

      module TargetMethods

        #
        # TODO
        #
        def apply_date_custom_field(name, accessors_module)
          # puts "...define singleton methods :#{name} / :formatted_#{name} & :#{name}= / :formatted_#{name}=" # DEBUG

          # # getter
          # define_singleton_method(name) { get_date(name) }
          # define_singleton_method(:"formatted_#{name}") { get_formatted_date(name) }
          #
          # # setter
          # define_singleton_method(:"#{name}=") { |value| set_date(name, value) }
          # define_singleton_method(:"formatted_#{name}=") { |value| set_formatted_date(name, value) }

          accessors_module.class_eval <<-EOV
            def #{name}
              get_date('#{name}')
            end

            def formatted_#{name}
              get_formatted_date('#{name}')
            end

            def #{name}=(value)
              set_date('#{name}', value)
            end

            def formatted_#{name}=(value)
              set_formatted_date('#{name}', value)
            end
          EOV
        end

        protected

        def get_date(name)
          self.date_serializer.deserialize(self.read_attribute(name.to_s))
        end

        def set_date(name, value)
          # puts "set_date #{name} = #{value}" # DEBUG

          value = self.date_serializer.serialize(value)

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

        #:nodoc:
        def date_serializer
          @date_serializer = ::Mongoid::Fields::Serializable::Date.new
        end

      end

    end
  end
end