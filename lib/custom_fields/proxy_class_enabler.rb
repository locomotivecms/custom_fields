module CustomFields
  module ProxyClassEnabler

    extend ActiveSupport::Concern

    included do

      # cattr_accessor :klass_with_custom_fields

      def self.to_klass_with_custom_fields(fields, parent, association_name)
        # return klass_with_custom_fields unless klass_with_custom_fields.nil?
        # return self.klass_with_custom_fields unless self.klass_with_custom_fields.nil?

        puts "[proxy_class_enabler][to_klass...] association_name = #{association_name}"
        puts "[proxy_class_enabler][to_klass...] number of fields #{[*fields].size} / #{fields.inspect}"

        target_name = "#{association_name}_proxy_class"

        klass = parent.instance_variable_get(:"@#{target_name}")

        if klass.nil?
          puts "[proxy_class_enabler][to_klass...] klass missing #{target_name}"

          klass = Class.new(self)
          klass.class_eval <<-EOF
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

          # valid_fields = [*fields].delete_if { |f| !f.valid? }

          klass.association_name = association_name
          klass._parent = parent

          [*fields].each { |field| klass.apply_custom_field(field) }

          # klass.custom_fields = valid_fields

          # valid_fields.each { |field| field.apply(klass) }

          # self.klass_with_custom_fields = klass
          # klass_with_custom_fields = klass

          puts "[proxy_class_enabler][to_klass...] done"

          # self.klass_with_custom_fields

          parent.instance_variable_set(:"@#{target_name}", klass)
        end

        klass
      end

      # def self.invalidate_klass_with_custom_fields
      #   puts "[proxy_class_enabler][to_klass...] invalidating #{self.name}"
      #   self.klass_with_custom_fields = nil # hoping Ruby GC will clean the previous one
      # end

    end

  end
end