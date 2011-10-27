module CustomFields
  module ProxyClass

    module Builder

      # Returns the proxy class based on the current class and enhanced by the custom fields.
      # If the custom fields have been modified, then a new version
      # of the proxy class is built
      #
      # @param [ String, Symbol ] name The name of the relation in the parent object
      # @param [ Document ] parent The parent document describing the custom fields
      # @param [ List ] fields The list of custom fields
      #
      # @return [ Class ] The proxy class.
      #
      def to_klass_with_custom_fields(name, parent, fields)
        klass = self.klass_with_custom_fields(name, parent)

        if klass && klass.version != self.klass_version_with_custom_fields(name, parent) # new version ?
          self.invalidate_klass_with_custom_fields(name, parent)
          klass = nil
        end

        if klass.nil?
          klass       = self.build_klass_with_custom_fields(name, parent, fields)
          klass_name  = self.klass_name_with_custom_fields(name, parent)

          Object.const_set(klass_name, klass)
        end

        klass
      end

      # Builds the proxy class based on the current class and enhanced by the custom fields.
      #
      # @param [ String, Symbol ] name The name of the relation in the parent object
      # @param [ Document ] parent The parent document describing the custom fields
      # @param [ List ] fields The list of custom fields
      #
      # @return [ Class ] The proxy class.
      #
      def build_klass_with_custom_fields(name, parent, fields)
        # puts "CREATING new '#{name}' klass (#{self.klass_version_with_custom_fields(name, parent)})"
        Class.new(self).tap do |klass|
          klass.send :include, CustomFields::ProxyClass::Base

          # copy scopes from the parent class (scopes does not inherit automatically from the parents in mongoid)
          klass.write_inheritable_attribute(:scopes, self.scopes)

          klass.association_name  = name.to_sym
          klass._parent           = parent
          klass.version           = self.klass_version_with_custom_fields(name, parent)

          [*fields].each { |field| klass.apply_custom_field(field) }
        end
      end
    end

  end
end