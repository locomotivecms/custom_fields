module Mongoid # :nodoc:
  module Relations #:nodoc:

    module Builders
      extend ActiveSupport::Concern

      module ClassMethods #:nodoc:

        def builder_with_custom_fields(name, metadata)
          tap do
            define_method("build_#{name}") do |*args|
              if self.custom_fields?(metadata.name)
                metadata = self.clone_metadata_for_custom_fields(metadata)
              end

              document = Factory.build(metadata.klass, args.first || {})
              send("#{name}=", document, :binding => true)
            end
          end
        end

        alias_method_chain :builder, :custom_fields

      end
    end
  end
end