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
        # puts "\t[create_relation / #{metadata.name}] #{self.inspect} \ object = #{object.inspect} / metadata = #{metadata.object_id}"

        # association_name = metadata.name.to_s.gsub(/^_/, '')

        # if custom_fields?(self, association_name)
        if self.respond_to?(:custom_fields?) && self.custom_fields?(metadata.name)
          # metadata = metadata.clone # 2 parent instances should not share the exact same option instance

          # custom_fields = self.send(:"ordered_#{custom_fields_association_name(association_name)}")
          #
          # klass = metadata.klass.to_klass_with_custom_fields(custom_fields, self, association_name)

          # klass = self.send(:"fetch_#{association_name.to_s.singularize}_klass")

          # metadata = metadata.clone # safer to do that because we are going to modify the metadata klass for next operations

          # puts "\t[create_relation / #{metadata.name}] klass = #{klass.inspect} / #{metadata.object_id}"

          # metadata.instance_variable_set(:@klass, klass)

          metadata = self.clone_metadata_for_custom_fields(metadata)
        end

        # puts "\t[create_relation / #{metadata.name}] going deeper"

        foo = create_relation_without_custom_fields(object, metadata)

        # puts "\t[create_relation / #{metadata.name}] done for #{metadata.name} ========== / #{metadata.object_id}"

        foo
      end

      alias_method_chain :create_relation, :custom_fields

      # def custom_fields_association_name(association_name)
      #   "#{association_name.to_s.singularize}_custom_fields".to_sym
      # end
      #
      # def custom_fields?(object, association_name)
      #   object.respond_to?(custom_fields_association_name(association_name))
      # end

    end

  end
end