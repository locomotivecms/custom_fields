# encoding: utf-8
module Mongoid #:nodoc:
  module Relations #:nodoc:
    module Referenced #:nodoc:

      # This class defines the behaviour for all relations that are a
      # one-to-many between documents in different collections.
      class Many < Relations::Many

        def build_with_custom_fields(attributes = {}, options = {}, type = nil)
          if base.custom_fields_for?(metadata.name)
            # puts "build powered by custom_fields #{attributes.inspect}" # DEBUG

            default_attribute = {
              :custom_fields_recipe => {
                'name'     => "#{metadata.name.to_s.classify}#{base._id}",
                'rules'    => base.custom_fields_recipe_for(metadata.name),
                'version'  => 0
              }
            }

            build_without_custom_fields(default_attribute, options, type).tap do |doc|
              doc.attributes = attributes
            end

          else
            build_without_custom_fields(attributes, options, type)
          end

          # attributes[:custom_fields_recipe] = base.custom_fields_recipe_for(metadata.name)
          # doc.custom_fields_recipe = base.custom_fields_recipe_for(metadata.name)

          # .tap do |doc|
          #   if base.custom_fields_for?(metadata.name)
          #     puts "build powered by custom_fields" # DEBUG
          #     doc.custom_fields_recipe = base.custom_fields_recipe_for(metadata.name)
          #   end
          # end
        end

        alias_method_chain :build, :custom_fields

      end

    end
  end
end