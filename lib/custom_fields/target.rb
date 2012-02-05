module CustomFields

  module Target

    extend ActiveSupport::Concern

    included do

      ## types ##
      %w(default string text date boolean file select belongs_to has_many many_to_many).each do |type|
        include "CustomFields::Types::#{type.classify}::Target".constantize
      end

      include ::CustomFields::TargetHelpers

      ## fields ##
      field :custom_fields_recipe, :type => Hash

    end

    module ClassMethods

      # A document with custom fields always returns true.
      #
      # @return [ Boolean ] True
      #
      def with_custom_fields?
        true
      end

      # Builds the custom klass by sub-classing it
      # from its parent and by applying a recipe
      #
      # @param [ Hash ] recipe The recipe describing the fields to add
      #
      # @return [ Class] the anonymous custom klass
      #
      def build_klass_with_custom_fields(recipe)
        name = recipe['name']

        # puts "CREATING #{name}, #{recipe.inspect}" # DEBUG

        parent.const_set(name, Class.new(self)).tap do |klass|
          klass.cattr_accessor :version

          klass.version = recipe['version']

          # copy scopes from the parent class (scopes does not inherit automatically from the parents in mongoid)
          # FIXME (Did): not needed anymore ?
          # klass.write_inheritable_attribute(:scopes, self.scopes)

          recipe['rules'].each do |rule|
            self.send(:"apply_#{rule['type']}_custom_field", klass, rule)
          end
        end
      end

      # Returns a custom klass always up-to-date. If it does not
      # exist or if the version is out-dates then build a new custom klass.
      # The recipe also contains the name which will be assigned to the
      # custom klass.
      #
      # @param [ Hash ] recipe The recipe describing the fields to add
      #
      # @return [ Class ] the custom klass
      #
      def klass_with_custom_fields(recipe)
        name = recipe['name']

        (modules = self.name.split('::')).pop

        parent = modules.empty? ? Object : modules.join('::').constantize

        klass = parent.const_defined?(name) ? parent.const_get(name) : nil

        if klass.nil? || klass.version != recipe['version'] # no klass or out-dated klass
          parent.send(:remove_const, name) if klass

          klass = build_klass_with_custom_fields(recipe)
        end

        klass
      end

    end


  end

end