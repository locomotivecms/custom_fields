module CustomFields
  module ProxyClassEnabler

    extend ActiveSupport::Concern

    included do

      def self.to_klass_with_custom_fields(fields, parent, association_name)
        # klass_name = self.klass_name_with_custom_fields(parent, association_name)
        #
        # klass = Object.const_defined?(klass_name) ? Object.const_get(klass_name): nil

        klass = self.current_klass_with_custom_fields(parent, association_name)

        if klass.nil?
          puts "[#{association_name} / #{parent.name rescue 'unknown'}] no klass found"
        else
          puts "[#{association_name} / #{parent.name rescue 'unknown'}] klass nil ? #{klass.nil?} / built at ? #{klass.built_at.inspect rescue ''} / parent ? #{self.custom_fields_updated_at(parent, association_name)}" # for debug purpose
        end

        if klass && klass.built_at != self.custom_fields_updated_at(parent, association_name) # new version ?
          self.invalidate_proxy_class_with_custom_fields(parent, association_name)
          klass = nil
        end

        if klass.nil?
          klass = self.build_proxy_class_with_custom_fields(fields, parent, association_name)

          klass_name = self.klass_name_with_custom_fields(parent, association_name)

          Object.const_set(klass_name, klass)
        end

        klass
      end

      def self.custom_fields_updated_at(parent, association_name)
        parent.send(:"#{association_name.to_s.singularize}_custom_fields_updated_at").try(:utc)
      end

      def self.invalidate_proxy_class_with_custom_fields(parent, association_name)
        klass_name = self.klass_name_with_custom_fields(parent, association_name)

        if Object.const_defined?(klass_name)
          Object.send(:remove_const, klass_name)
        end
      end

      def self.current_klass_with_custom_fields(parent, association_name)
        klass_name = self.klass_name_with_custom_fields(parent, association_name)

        Object.const_defined?(klass_name) ? Object.const_get(klass_name): nil
      end

      def self.klass_name_with_custom_fields(parent, association_name)
        "#{association_name.to_s.gsub(/^_/, '').singularize.camelize}#{parent.class.name.camelize}#{parent._id}"
      end

      def self.build_proxy_class_with_custom_fields(fields, parent, association_name)
        puts "BUILDING PROXY CLASS #{association_name}" # for debug purpose

        (klass = Class.new(self)).class_eval <<-EOF

          cattr_accessor :custom_fields, :_parent, :association_name, :built_at

          def self.model_name
            @_model_name ||= ActiveModel::Name.new(self.superclass)
          end

          def self.apply_custom_field(field)
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

        [*fields].each { |field| klass.apply_custom_field(field) }

        klass.built_at = self.custom_fields_updated_at(parent, association_name)

        klass
      end

    end

  end
end