module Mongoid # :nodoc:
  module Relations #:nodoc:

    module Builders

      module ClassMethods #:nodoc:

        def builder_with_custom_fields(name, metadata)
          puts "builder_with_custom_fields #{name}"
          tap do
            define_method("build_#{name}") do |*args|
              if self.custom_fields_for?(metadata.name)
                metadata = self.clone_metadata_for_custom_fields(metadata)
              end

              attributes = args.first || {}
              options = args.size > 1 ? args[1] : {}
              document = Factory.build(metadata.klass, attributes, options)
              _building do
                send("#{name}=", document)
              end
            end
          end
        end

        alias_method_chain :builder, :custom_fields

      end
    end
  end
end