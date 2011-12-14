module CustomFields
  module AccessorsBuilder

    extend ActiveSupport::Concern

    module InstanceMethods

      #
      # TODO
      #
      def build_custom_fields_accessors_module
        puts "build_custom_fields_accessors_module version = #{self.custom_fields_recipe['version']}" # DEBUG

        Module.new.tap do |accessors_module|
          accessors_module.class_eval <<-EOV
            def self.version
              #{self.custom_fields_recipe['version']}
            end
          EOV

          self.custom_fields_recipe['rules'].each do |rule|
            # puts "rule = #{rule.inspect}" # DEBUG

            # next if rule['type'] != 'string' # DEBUG
            # next if self.singleton_methods.include?(rule['name'].to_sym)

            self.send(:"apply_#{rule['type']}_custom_field", rule['name'], accessors_module)
          end
        end
      end

      #
      # TODO
      #
      def custom_fields_accessors_module
        name  = "#{self.custom_fields_recipe['name']}Accessors"

        # puts "accessors_module name = #{name}"

        m = Object.const_defined?(name) ? Object.const_get(name) : nil

        if m.nil? || m.version != self.custom_fields_recipe['version']
          Object.send(:remove_const, name) if m

          m = build_custom_fields_accessors_module

          Object.const_set(name, m)
        end

        m
      end

    end

  end
end
