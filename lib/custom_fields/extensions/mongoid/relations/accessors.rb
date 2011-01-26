# encoding: utf-8
module Mongoid # :nodoc:
  module Relations #:nodoc:

    module Accessors

      # Create a relation from an object and metadata.
      #
      # @example Create the relation.
      #   person.create_relation(document, metadata)
      #
      # @param [ Document, Array<Document ] object The relation target.
      # @param [ Metadata ] metadata The relation metadata.
      #
      # @return [ Proxy ] The relation.
      #
      # @since 2.0.0.rc.1
      def create_relation_with_custom_fields(object, metadata)
        if custom_fields?(self, metadata.name)
          metadata = metadata.clone # 2 parent instances should not share the exact same option instance

          custom_fields = self.send(:"ordered_#{custom_fields_association_name(metadata.name)}")

          klass = metadata.klass.to_klass_with_custom_fields(custom_fields, self, metadata.name)

          metadata.instance_variable_set(:@klass, klass)
        end

        create_relation_without_custom_fields(object, metadata)
      end

      alias_method_chain :create_relation, :custom_fields

      def custom_fields_association_name(association_name)
        "#{association_name.to_s.singularize}_custom_fields".to_sym
      end

      def custom_fields?(object, association_name)
        object.respond_to?(custom_fields_association_name(association_name))
      end

    end

  end
end