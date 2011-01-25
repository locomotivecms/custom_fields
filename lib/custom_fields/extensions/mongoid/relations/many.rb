# # encoding: utf-8
# module Mongoid #:nodoc:
#   module Relations #:nodoc:
#
#     # This is the superclass for all many to one and many to many relation
#     # proxies.
#     class Many < Proxy
#
#       # def initialize_with_custom_fields(parent, metadata, target_array = nil)
#
#       def init_with_custom_fields(base, target, metadata)
#         # puts "[many][init][#{base.class.name}] base = #{base.inspect} (#{base.object_id}), \n\t#{target.inspect}" #, \n\t#{metadata.inspect}"
#
#         if custom_fields?(base, metadata.name)
#           # puts "[many][init] custom_fields? => true #{metadata.name} / #{metadata.klass.inspect} / #{}"
#
#           metadata = metadata.clone # 2 parent instances should not share the exact same option instance
#
#           custom_fields = base.send(:"ordered_#{custom_fields_association_name(metadata.name)}")
#
#           # puts "really here ????? ---> #{base.object_id} / #{target[0].inspect} (#{target[0].object_id}) (#{target[0]._parent.present?})" unless target.blank?
#           klass = metadata.klass.to_klass_with_custom_fields(custom_fields, base, metadata.name)
#           # puts "<----- done"
#
#           # klass._parent = base
#           # klass.association_name = metadata.name
#
#           # metadata.instance_eval <<-EOF
#           #   def klass=(klass); @klass = klass; end
#           #   def klass; @klass || class_name.constantize; end
#           # EOF
#
#           # puts "metadata.klass = #{klass.object_id}, #{klass.inspect} / #{klass._parent.inspect} / #{metadata.object_id}"
#
#           # metadata.klass = klass
#           metadata.instance_variable_set(:@klass, klass)
#         end
#
#         # puts "===================> metdata = #{metadata.inspect} #{metadata.klass.inspect}"
#
#         # puts "[init_with_custom_fields] 1er <------- #{metadata.klass.object_id}"
#
#         init_without_custom_fields(base, target, metadata)
#
#         # puts "[init_with_custom_fields] 2nd <------- #{self.metadata.klass.object_id} #{self.object_id}"
#       end
#
#       alias_method_chain :init, :custom_fields
#
#       def custom_fields_association_name(association_name)
#         "#{association_name.to_s.singularize}_custom_fields".to_sym
#       end
#
#       def custom_fields?(object, association_name)
#         object.respond_to?(custom_fields_association_name(association_name))
#       end
#
#     end
#
#   end
# end