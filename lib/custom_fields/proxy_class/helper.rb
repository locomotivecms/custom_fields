module CustomFields
  module ProxyClass

    module Helper

      # Gets the name of the proxy class built with the custom fields.
      #
      # @param [ String, Symbol ] name The name of the relation in the parent object
      # @param [ Document ] parent The parent document describing the custom fields
      #
      # @return [ String ] The class name
      #
      def klass_name_with_custom_fields(name, parent)
        "#{name.to_s.gsub(/^_/, '').singularize.camelize}#{parent.class.name.demodulize.camelize}#{parent._id}"
      end

      # Returns the current proxy class built with the custom fields.
      #
      # @param [ String, Symbol ] name The name of the relation in the parent object
      # @param [ Document ] parent The parent document describing the custom fields
      #
      # @return [ Class ] The proxy class
      #
      def klass_with_custom_fields(name, parent)
        klass_name = self.klass_name_with_custom_fields(name, parent)
        Object.const_defined?(klass_name) ? Object.const_get(klass_name): nil
      end

      # Returns the version of the proxy class built with the custom fields.
      #
      # @param [ String, Symbol ] name The name of the relation in the parent object
      # @param [ Document ] parent The parent document describing the custom fields
      #
      # @return [ String ] The class name
      #
      def klass_version_with_custom_fields(name, parent)
        parent.send(:"#{name}_custom_fields_version")
      end

      # Destroy the class enhanced by the custom fields so that next time we need it,
      # we have a fresh new one.
      #
      # @param [ String, Symbol ] name The name of the relation in the parent object
      # @param [ Document ] parent The parent document describing the custom fields
      #
      def invalidate_klass_with_custom_fields(name, parent)
        klass_name = self.klass_name_with_custom_fields(name, parent)

        if Object.const_defined?(klass_name)
          Object.send(:remove_const, klass_name)
        end
      end

    end

  end
end
