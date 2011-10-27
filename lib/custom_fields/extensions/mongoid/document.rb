# encoding: utf-8
module Mongoid #:nodoc:

  # # This is the base module for all domain objects that need to be persisted to
  # # the database as documents.
  # module Document
  #
  #   # Reloads the +Document+ attributes from the database. If the document has
  #   # not been saved then an error will get raised if the configuration option
  #   # was set.
  #   #
  #   # @example Reload the document.
  #   #   person.reload
  #   #
  #   # @raise [ Errors::DocumentNotFound ] If the document was deleted.
  #   #
  #   # @return [ Document ] The document, reloaded.
  #   def reload_with_custom_fields
  #     reload_without_custom_fields.tap do
  #       instance_variable_names.each do |name|
  #         if name =~ /_proxy_class$/
  #           remove_instance_variable("#{name}")
  #         end
  #       end
  #     end
  #   end
  #
  #   alias_method_chain :reload, :custom_fields
  #
  # end

  # This is the base module for all domain objects that need to be persisted to
  # the database as documents.
  module Reloading

    # Reloads the +Document+ attributes from the database. If the document has
    # not been saved then an error will get raised if the configuration option
    # was set.
    #
    # @example Reload the document.
    #   person.reload
    #
    # @raise [ Errors::DocumentNotFound ] If the document was deleted.
    #
    # @return [ Document ] The document, reloaded.
    def reload_with_custom_fields
      reload_without_custom_fields.tap do
        instance_variable_names.each do |name|
          if name =~ /_proxy_class$/
            remove_instance_variable("#{name}")
          end
        end
      end
    end

    alias_method_chain :reload, :custom_fields

  end
end