# encoding: utf-8
module Mongoid # :nodoc:
  module Relations #:nodoc:

    module Accessors

      # Builds the related document and creates the relation based on the class
      # enhanced by the custom_fields functionnality (if set up for the relation).
      #
      # @param [ String, Symbol ] name The name of the relation.
      # @param [ Hash, BSON::ObjectId ] object The id or attributes to use.
      # @param [ Metadata ] metadata The relation's metadata.
      # @param [ true, false ] building If we are in a build operation.
      #
      # @return [ Proxy ] The relation.
      #
      # @since 2.0.0.rc.1
      def build_with_custom_fields(name, object, metadata)
        if self.respond_to?(:custom_fields_for?) && self.custom_fields_for?(metadata.name)
          metadata = self.clone_metadata_for_custom_fields(metadata)
        end

        build_without_custom_fields(name, object, metadata)
      end

      alias_method_chain :build, :custom_fields
    end

  end
end