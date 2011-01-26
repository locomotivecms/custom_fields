module CustomFields
  module ProxyClassEnabler

    extend ActiveSupport::Concern

    included do

      def self.to_klass_with_custom_fields(fields, parent, association_name)
        target_name = "#{association_name}_proxy_class"

        klass = parent.instance_variable_get(:"@#{target_name}")

        if klass.nil?
          klass = self.build_proxy_class_with_custom_fields(fields, parent, association_name)

          parent.instance_variable_set(:"@#{target_name}", klass)
        end

        klass
      end

      def self.build_proxy_class_with_custom_fields(fields, parent, association_name)
        (klass = Class.new(self)).class_eval <<-EOF

          cattr_accessor :custom_fields, :_parent, :association_name

          def self.model_name
            @_model_name ||= ActiveModel::Name.new(self.superclass)
          end

          def self.apply_custom_field(field)
            return unless field.valid?

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

        klass.association_name = association_name
        klass._parent = parent

        [*fields].each { |field| klass.apply_custom_field(field) }

        klass
      end

    end

  end
end