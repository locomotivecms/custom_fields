module CustomFields

  module Target

    extend ActiveSupport::Concern

    included do

      ## modules ##
      # include AccessorsBuilder
      # include Types::Default::TargetMethods
      extend Types::String::TargetMethods
      # include Types::Text::TargetMethods
      # include Types::Date::TargetMethods
      # include Types::Boolean::TargetMethods
      # include Types::File::TargetMethods

      ## fields ##
      field :custom_fields_recipe, :type => Hash

      ## callbacks ##
      # after_initialize :enhance_with_custom_fields

      ## accessors ##
      # attr_accessor :enhanced_with_custom_fields
    end

    # module Foo
    #
    #   def location=(value); end
    #   def location; end
    #
    #   def main_author=(value); end
    #   def main_author; end
    #
    #   def posted_at=(value); end
    #   def formtatted_posted_at=(value); end
    #   def posted_at; end
    #   def formatted_posted_at; end
    #
    #   def published=(value); end
    #   def published; end
    #
    # end

    module InstanceMethods

      #
      # TODO
      #
      def enhanced_with_custom_fields?
        !!self.enhanced_with_custom_fields
      end

      protected

      #
      # TODO
      #
      def enhance_with_custom_fields
        # puts "[enhance_with_custom_fields] #{self.singleton_methods.inspect} / #{self.enhanced_with_custom_fields?} / #{self.custom_fields_recipe.inspect}" # DEBUG

        return if self.custom_fields_recipe.blank? || self.enhanced_with_custom_fields?

        # singleton_class.send(:include, Foo)
        singleton_class.send(:include, self.custom_fields_accessors_module)

        # self.custom_fields_recipe.each do |rule|
        #   # puts "rule = #{rule.inspect}" # DEBUG
        #
        #   # next if self.singleton_methods.include?(rule['name'].to_sym)
        #
        #   self.send(:"apply_#{rule['type']}_custom_field", rule['name'])
        # end

        # prepare_custom_fields_validation

        # validate_presence_of_custom_fields

        self.enhanced_with_custom_fields = true
      end

      # #
      # # TODO
      # #
      # def prepare_custom_fields_validation
      #   # tie _validators to the singleton class instead of the class
      #   self.singleton_class.cattr_accessor :_validators
      #   self.singleton_class._validators = self.class._validators.clone
      # end

      # #
      # # TODO
      # #
      # def validate_presence_of_custom_fields
      #   puts "singleton_class = #{self.singleton_class.object_id}"
      #   puts self.singleton_class.validators.inspect
      #
      #   names = self.custom_fields_recipe.find_all do |rule|
      #     !!rule['required'] && self.singleton_class.validators_on(rule['name']).empty?
      #   end.map { |rule| rule['name'] }
      #
      #   puts "validates_presence_of #{names.inspect}" # DEBUG
      #
      #   return if names.empty?
      #
      #   self.singleton_class.validates_presence_of names
      # end

      #
      # TODO
      #
      # def apply_custom_field_rule(rule)
      #   unless self.singleton_methods.include?(rule['name'].to_sym)
      #     self.send(:"apply_#{rule['type']}_custom_field", rule['name'])
      #   end
      # end

      #
      # TODO
      #
      # def add_custom_field_validation(rule)
      #   puts "required? #{!!rule['required'].inspect} && validators #{self.singleton_class.validators_on(rule['name']).inspect}"
      #   if !!rule['required'] && self.singleton_class.validators_on(rule['name']).empty?
      #     puts "ADD VALIDATES_PRESENCE_OF #{} for the singleton class"
      #   end
      # end

      #
      # TODO
      #

      # def validate_presence_of_custom_fields
      #   puts "[validate_presence_of_custom_fields]" # DEBUG
      #
      #   self.custom_fields_recipe.each do |rule|
      #
      #   end
      # end

    end

    module ClassMethods

      #
      # TODO
      #
      def with_custom_fields?
        true
      end

      #
      # TODO
      #
      def ensure_klass_with_custom_fields(recipe)
        # puts "ensure_klass_with_custom_fields #{recipe.inspect}" # DEBUG
        klass_with_custom_fields(recipe)
      end

      #
      # TODO
      #
      def build_klass_with_custom_fields(recipe)
        # puts "CREATING new '#{name}' klass (#{self.klass_version_with_custom_fields(name, parent)})" # DEBUG
        Class.new(self).tap do |klass|
          klass.cattr_accessor :version

          klass.version = recipe['version']

          # copy scopes from the parent class (scopes does not inherit automatically from the parents in mongoid)
          klass.write_inheritable_attribute(:scopes, self.scopes)

          recipe['rules'].each do |rule|
            self.send(:"apply_#{rule['type']}_custom_field", klass, rule['name'])
          end
        end
      end

      #
      # TODO
      #
      def klass_with_custom_fields(recipe)
        name = recipe['name']

        # puts "klass name = #{name}"

        (modules = self.name.split('::')).pop

        parent = modules.empty? ? Object : modules.join('::').constantize

        klass = parent.const_defined?(name) ? parent.const_get(name) : nil

        if klass.nil? || klass.version != recipe['version']
          parent.send(:remove_const, name) if klass

          klass = build_klass_with_custom_fields(recipe)

          parent.const_set(name, klass)
        end

        klass
      end

    end


  end

end