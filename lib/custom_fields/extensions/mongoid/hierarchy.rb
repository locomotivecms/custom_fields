# # encoding: utf-8
# module Mongoid #:nodoc
#   module Hierarchy #:nodoc
#     module InstanceMethods
#
#       # def parentize_with_custom_fields(object, association_name)
#       def parentize_with_custom_fields(object)
#         if self.do_or_do_not(:custom_field?)
#           # puts "[parentize] self = #{self.inspect}, object = #{object.inspect}, relations ? #{self.relations.inspect}"
#
#           object_name = object.class.to_s.underscore
#
#           # self.metadata ||= self.relations[object_name] # self.metadata is not always set (we lost it when we reload a model instance). bug in mongoid ?
#
#           # puts "[parentize] self.metadata = #{self.metadata.inspect} / #{self.relations.size}"
#
#           self.association_name = self.metadata ? self.metadata.name : self.relations[object_name].inverse_of
#
#           # if self.metadata.nil?
#
#             # self.relations is up-to-date though
#
#             # self.association_name = self.relations[object_name].name
#
#             # puts "[parentize] ___ metadata not found ___ #{self.inspect} (#{self.object_id}), #{object.inspect}, #{self.association_name}"
#             # return parentize_without_custom_fields(object)
#             # return object
#           # end
#
#           # self.association_name = self.metadata.name
#
#           if !self.relations.key?(object_name)
#             self.singleton_class.embedded_in object_name.to_sym, :inverse_of => self.association_name
#             puts "[parentize] embedded_in DONE !"
#           else
#             puts "[parentize] ___ embedded_in already done ___"
#           end
#
#           # self.association_name = association_name
#
#           parentize_without_custom_fields(object)
#
#           self.send(:set_unique_name!)
#           self.send(:set_alias)
#         else
#           puts "[parentize] ___ not a custom field ___"
#
#           parentize_without_custom_fields(object)
#         end
#       end
#
#
#         # relation = self.relations[object_name]
#
#
#
#         # # puts "[parentize_with_custom_fields] #{self.object_id} with #{object.object_id} (#{self.inspect}), #{self.relations.inspect}"
#         #  puts "[parentize_with_custom_fields] self = #{self.inspect}, object = #{object.inspect}, relations ? #{self.relations.inspect}"
#         #
#         #  association_name = self.metadata.name # ???
#         #
#         #  object_name = object.class.to_s.underscore
#         #
#         #  # puts "association_name = #{association_name}"
#         #
#         #
#         #  if association_name.to_s.ends_with?('_custom_fields')
#         #    puts "[parentize_with_custom_fields] custom_fields relationship found ! #{association_name}"
#         #
#         #    if !self.relations.key?(object_name)
#         #
#         #      # self.singleton_class.associations = {}
#         #      self.singleton_class.embedded_in object_name.to_sym, :inverse_of => association_name
#         #
#         #      puts "[parentize_with_custom_fields] embedded_in DONE !"
#         #
#         #      # if self.embedded?
#         #        # puts "set association_name = #{association_name}"
#         #        self.association_name = association_name
#         #        # object.instance_variable_set(:"@association_name", association_name)
#         #      # end
#         #    else
#         #      puts "[parentize_with_custom_fields] embedded_in ALREADY EXISTS !!!!!!!"
#         #    end
#         #  end
#         #
#         #  parentize_without_custom_fields(object)
#         #
#         #  # not sure, it still works
#         #
#         #  # if self.embedded? && self.instance_variable_get(:"@association_name").nil?
#         #  #    puts "set association_name = #{association_name}"
#         #  #    self.instance_variable_set(:"@association_name", association_name) # weird bug with proxy class
#         #  #  end
#         #
#         #  if association_name.to_s.ends_with?('_custom_fields')
#         #    self.send(:set_unique_name!)
#         #    self.send(:set_alias)
#         #  end
#         #
#         #  puts "[parentize_with_custom_fields] end"
#       # end
#
#       alias_method_chain :parentize, :custom_fields
#
#     end
#   end
# end