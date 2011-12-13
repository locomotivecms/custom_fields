module CustomFields

  module Target

    extend ActiveSupport::Concern

    included do
      include CustomFields::Types::Default::TargetMethods
      include CustomFields::Types::String::TargetMethods
      include CustomFields::Types::Text::TargetMethods
      include CustomFields::Types::Date::TargetMethods
      include CustomFields::Types::Boolean::TargetMethods
      include CustomFields::Types::File::TargetMethods

      field :custom_fields_recipe, :type => Array

      after_initialize :enhance_with_custom_fields
    end

    module InstanceMethods

      def enhance_with_custom_fields
        puts "[enhance_with_custom_fields] #{self.singleton_methods.inspect}" # DEBUG

        return if self.custom_fields_recipe.nil?

        self.custom_fields_recipe.each do |rule|
          puts "rule = #{rule.inspect}" # DEBUG

          next if self.singleton_methods.include?(rule['name'].to_sym)

          self.send(:"apply_#{rule['type']}_custom_field", rule['name'])
        end

        # puts "[enhance_with_custom_fields] AFTER #{self.singleton_methods.inspect}" # DEBUG
      end

    end

    module ClassMethods

    end


  end

end