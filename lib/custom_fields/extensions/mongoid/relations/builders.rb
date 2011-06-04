module Mongoid # :nodoc:
  module Relations #:nodoc:

    module Builders
      extend ActiveSupport::Concern

      module ClassMethods #:nodoc:

        def builder_with_custom_fields(name, metadata)
          tap do
            define_method("build_#{name}") do |*args|
              # puts "build_#{name} !!! / #{args.inspect} / #{metadata.klass} / #{metadata.object_id}"

              # puts "\t[build_#{name}_with_custom_fields] BEFORE klass = #{metadata.klass} / #{self.inspect} / #{metadata.object_id}"

              if self.custom_fields?(metadata.name)
                metadata = self.clone_metadata_for_custom_fields(metadata)
              end

              # puts "\t[build_#{name}_with_custom_fields] AFTER klass = #{metadata.klass} / #{self.inspect} / #{metadata.object_id}"

              document = Factory.build(metadata.klass, args.first || {})
              send("#{name}=", document, :binding => true)
            end
          end

          # puts "custom_fields? = #{self.custom_fields.inspect}"
          #
          #           # if self.custom_fields?(metadata.name)
          #           #   metadata = self.clone_metadata_for_custom_fields(metadata)
          #           #
          #           #   # klass = self.send(:"fetch_#{name.to_s.gsub(/^_/, '')}_klass")
          #           #
          #           #   # safer to do that because we are going to modify the metadata klass and we do not want to keep track of our modifications
          #           #   # metadata = metadata.clone
          #           #
          #           #   # metadata.instance_variable_set(:@klass, klass)
          #           #
          #           #   puts "\t[builder_with_custom_fields] name = #{name} / klass = #{klass.inspect} / #{metadata.object_id}"
          #           # end
          #
          #           builder_without_custom_fields(name, metadata)
          #
          #           define_method("build_#{name}_with_custom_fields") do |*args|
          #             puts "\t[build_#{name}_with_custom_fields] BEFORE klass = #{metadata.klass} / #{self.inspect} / #{metadata.object_id}"
          #
          #             if self.custom_fields?(metadata.name)
          #               metadata = self.clone_metadata_for_custom_fields(metadata)
          #             end
          #
          #             puts "\t[build_#{name}_with_custom_fields] AFTER klass = #{metadata.klass} / #{self.inspect} / #{metadata.object_id}"
          #
          #             self.send(:"build_#{name}_without_custom_fields", *args)
          #           end
          #
          #           alias_method_chain :"build_#{name}", :custom_fields

          # class_eval do
          #
          #            define_method("build_#{name}_with_custom_fields") do |*args|
          #              puts "\t[build_#{name}_with_custom_fields] klass = #{metadata.klass} / #{self.inspect} / #{metadata.object_id}"
          #
          #
          #
          #              self.send(:"build_#{name}_without_custom_fields")
          #            end
          #
          #            alias_method_chain :"build_#{name}", :custom_fields
          #          end

          # puts "\t[builder_with_custom_fields] klass = #{metadata.klass} / #{self.inspect}"
          # tap do
          #   define_method("build_#{name}") do |*args|
          #     puts "build_#{name} !!! / #{args.inspect} / #{metadata.klass} / #{metadata.object_id}"
          #     document = Factory.build(metadata.klass, args.first || {})
          #     send("#{name}=", document, :binding => true)
          #   end
          # end
        end

        alias_method_chain :builder, :custom_fields

      end
    end
  end
end