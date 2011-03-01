module CustomFields
  module ProxyClassEnabler

    extend ActiveSupport::Concern

    included do

      def self.to_klass_with_custom_fields(fields, parent, association_name)
        # target_name = "#{association_name}_proxy_class"

        # klass = parent.instance_variable_get(:"@#{target_name}")

        klass_name = self.klass_name_with_custom_fields(parent, association_name)

        klass = Object.const_defined?(klass_name) ? Object.const_get(klass_name): nil

        if klass.nil?
          # puts "klass name = #{klass_name.inspect} / #{association_name} [CREATED] / defined? #{Object.const_defined?(klass_name).inspect}"
          # puts "klass created !!!!"
          klass = self.build_proxy_class_with_custom_fields(fields, parent, association_name)

          Object.const_set(klass_name, klass)
        end

        klass

        # if klass.nil?
        #   klass = self.build_proxy_class_with_custom_fields(fields, parent, association_name)
        #
        #   parent.instance_variable_set(:"@#{target_name}", klass)
        # end
        #
        # klass
      end

      def self.invalidate_proxy_class_with_custom_fields(parent, association_name)
        klass_name = self.klass_name_with_custom_fields(parent, association_name)

        if Object.const_defined?(klass_name)
          Object.send(:remove_const, klass_name)
        end
      end

      def self.klass_name_with_custom_fields(parent, association_name)
        "#{association_name.to_s.gsub(/^_/, '').singularize.camelize}#{parent.class.name.camelize}#{parent.id}"
      end

      def self.build_proxy_class_with_custom_fields(fields, parent, association_name)
        (klass = Class.new(self)).class_eval <<-EOF

          cattr_accessor :custom_fields, :_parent, :association_name

          def self.model_name
            @_model_name ||= ActiveModel::Name.new(self.superclass)
          end

          def self.apply_custom_field(field)
            # puts "field " + field.label.to_s + " persisted ? " + field.persisted?.to_s
            unless field.persisted?
              return unless field.valid?
            end

            (self.custom_fields ||= []) << field

            field.apply(self)
          end

          def self.lookup_custom_field(name)
            self.custom_fields.detect { |f| f._name == name }
          end

          def self.hereditary?
            false
          end

          def custom_fields
            self.class.custom_fields
          end

          def aliased_attributes
            hash = { :created_at => self.created_at, :updated_at => self.updated_at } rescue {}

            self.custom_fields.each do |field|
              case field.kind
              when 'file' then hash[field._alias] = self.send(field._name.to_sym).url
              else
                hash[field._alias] = self.send(field._name.to_sym)
              end
            end

            hash
          end
        EOF

        # copy scopes from the parent class
        klass.write_inheritable_attribute(:scopes, self.scopes)

        klass.association_name = association_name.to_sym
        klass._parent = parent

        MyBenchmark.measure('build_proxy_class_with_custom_fields / adding all the fields') do
          # [*fields].each { |field| puts "applying field #{field._alias}"; klass.apply_custom_field(field) }
          [*fields].each { |field| klass.apply_custom_field(field) }
        end

        # puts "klass relations = #{klass.relations.inspect} / parent = #{self.relations.inspect} (#{self.name})"

        klass
      end

    end

  end
end