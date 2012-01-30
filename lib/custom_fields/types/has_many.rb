# module CustomFields
#
#   module Types
#
#     module HasMany
#
#       module Field
#
#         extend ActiveSupport::Concern
#
#         included do
#
#           field :class_name
#           field :inverse_of
#
#           validates_presence_of :class_name
#
#           def belongs_to_to_recipe
#             { :class_name => self.class_name, :inverse_of => self.inverse_of }
#           end
#
#         end
#
#       end
#
#       module Target
#
#         extend ActiveSupport::Concern
#
#         module ClassMethods
#
#           # Adds a has_many relationship between 2 mongoid models
#           #
#           # @param [ Class ] klass The class to modify
#           # @param [ Hash ] rule It contains the name of the relation and if it is required or not
#           #
#           def apply_has_many_custom_field(klass, rule)
#             klass.belongs_to rule['name'], :class_name => rule['class_name'], :inverse_of => rule['inverse_of']
#
#             if rule['required']
#               klass.validates_length_of rule['name'], :minimum => 1
#             end
#           end
#
#         end
#
#       end
#
#     end
#
#   end
#
# end