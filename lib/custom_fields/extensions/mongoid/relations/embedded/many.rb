# # encoding: utf-8
# module Mongoid # :nodoc:
#   module Relations #:nodoc:
#     module Embedded #:nodoc:
#
#       # This class handles the behaviour for a document that embeds many other
#       # documents within in it as an array.
#       class Many < Relations::Many
#
#         # def initialize_with_custom_fields(parent, metadata, target_array = nil)
#
#         def initialize_with_custom_fields(base, target, metadata)
#           puts "[initialize_with_custom_fields] base = #{base.inspect}, \n\t#{target.inspect}, \n\t#{metadata.inspect}"
#
#           if custom_fields?(base, metadata.name)
#             puts "custom_fields? => true #{metadata.name} / #{metadata.klass.inspect}"
#
#             metadata = metadata.clone # 2 parent instances should not share the exact same option instance
#
#             custom_fields = base.send(:"ordered_#{custom_fields_association_name(metadata.name)}")
#
#             klass = metadata.klass.to_klass_with_custom_fields(custom_fields)
#
#             klass._parent = base
#             klass.association_name = metadata.name
#
#             # metadata.instance_eval <<-EOF
#             #   def klass=(klass); @klass = klass; end
#             #   def klass; @klass || class_name.constantize; end
#             # EOF
#
#             puts "metadata.klass = #{klass.object_id}, #{klass.inspect} / #{klass._parent.inspect} / #{metadata.object_id}"
#
#             # metadata.klass = klass
#             metadata.instance_variable_set(:@klass, klass)
#           end
#
#           puts "[initialize_with_custom_fields] 1er <------- #{metadata.klass.object_id}"
#
#           initialize_without_custom_fields(base, target, metadata)
#
#           puts "[initialize_with_custom_fields] 2nd <------- #{self.metadata.klass.object_id} #{self.object_id}"
#         end
#
#         alias_method_chain :initialize, :custom_fields
#
#       end
#
#     end
#   end
# end