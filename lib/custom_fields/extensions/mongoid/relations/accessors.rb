# encoding: utf-8
module Mongoid # :nodoc:
  module Relations #:nodoc:

    # This module contains all the behaviour related to accessing relations
    # through the getters and setters, and how to delegate to builders to
    # create new ones.
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
        # puts "[relations][create_relation] #{object.inspect}, self (base)= #{self.inspect}, metadata = #{metadata.name}"

        if custom_fields?(self, metadata.name)
          puts "[relations][create_relation] creating and assigning proxy class #{metadata.name} / #{metadata.klass.object_id} / #{object.class.name} (#{object.object_id})"
          # puts "[relations][create_relation] self #{self.class.name} (#{self.object_id}), #relations #{self.relations.size}"

          # puts "[relations][create_relation] metadata custom fields (#{metadata.object_id})? = #{metadata.instance_variable_get(:@custom_fields)}"

          puts "[relations][create_relation] metadata custom fields (#{metadata.object_id})"

          # if object.nil? # first time ?

          # if metadata.instance_variable_get(:@custom_fields) != true
            # previous_metadata = metadata

            metadata = metadata.clone # 2 parent instances should not share the exact same option instance

            custom_fields = self.send(:"ordered_#{custom_fields_association_name(metadata.name)}")

            klass = metadata.klass.to_klass_with_custom_fields(custom_fields, self, metadata.name)

            metadata.instance_variable_set(:@klass, klass)

            # puts "[relations][create_relation] setting instance variable for @custom_fields (#{metadata.name})"

            # [previous_metadata, metadata].each { |m| m.instance_variable_set(:@custom_fields, true) }

          # else
            # puts "[relations][create_relation] proxy class already assigned"
          # end
          # end
        end

        # puts "[relations][create_relation] metadata custom fields (after) = #{metadata.instance_variable_get(:@custom_fields)}"

        foo = create_relation_without_custom_fields(object, metadata)

        # puts "[relations][create_relation] done #{object.class.name} (#{object.object_id}) (#{metadata.object_id})"

        # type = @attributes[metadata.inverse_type]
        # target = metadata.builder(object).build(type)
        # target ? metadata.relation.new(self, target, metadata) : nil

        foo
      end

      alias_method_chain :create_relation, :custom_fields

      def custom_fields_association_name(association_name)
        "#{association_name.to_s.singularize}_custom_fields".to_sym
      end

      def custom_fields?(object, association_name)
        object.respond_to?(custom_fields_association_name(association_name))
      end


      # def create_relation(base, target, metadata)
      #   # puts "[many][init][#{base.class.name}] base = #{base.inspect} (#{base.object_id}), \n\t#{target.inspect}" #, \n\t#{metadata.inspect}"
      #
      #   if custom_fields?(base, metadata.name)
      #     # puts "[many][init] custom_fields? => true #{metadata.name} / #{metadata.klass.inspect} / #{}"
      #
      #     metadata = metadata.clone # 2 parent instances should not share the exact same option instance
      #
      #     custom_fields = base.send(:"ordered_#{custom_fields_association_name(metadata.name)}")
      #
      #     # puts "really here ????? ---> #{base.object_id} / #{target[0].inspect} (#{target[0].object_id}) (#{target[0]._parent.present?})" unless target.blank?
      #     klass = metadata.klass.to_klass_with_custom_fields(custom_fields, base, metadata.name)
      #     # puts "<----- done"
      #
      #     # klass._parent = base
      #     # klass.association_name = metadata.name
      #
      #     # metadata.instance_eval <<-EOF
      #     #   def klass=(klass); @klass = klass; end
      #     #   def klass; @klass || class_name.constantize; end
      #     # EOF
      #
      #     # puts "metadata.klass = #{klass.object_id}, #{klass.inspect} / #{klass._parent.inspect} / #{metadata.object_id}"
      #
      #     # metadata.klass = klass
      #     metadata.instance_variable_set(:@klass, klass)
      #   end
      #
      #   # puts "===================> metdata = #{metadata.inspect} #{metadata.klass.inspect}"
      #
      #   # puts "[init_with_custom_fields] 1er <------- #{metadata.klass.object_id}"
      #
      #   init_without_custom_fields(base, target, metadata)
      #
      #   # puts "[init_with_custom_fields] 2nd <------- #{self.metadata.klass.object_id} #{self.object_id}"
      # end
      #
      # alias_method_chain :init, :custom_fields
      #
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