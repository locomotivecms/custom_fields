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
        if self.respond_to?(:custom_fields?) && self.custom_fields?(metadata.name)
          metadata = self.clone_metadata_for_custom_fields(metadata)
        end

        create_relation_without_custom_fields(object, metadata)
      end

      alias_method_chain :create_relation, :custom_fields
    end

  end
end