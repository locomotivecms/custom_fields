module CustomFields

  module CustomFieldsFor

    def self.included(base)
      base.extend(ClassMethods)
    end

    # Enhance an embedded collection OR the instance itself (by passing self) by providing methods to manage custom fields.
    #
    # class Company
    #
    #   custom_fields_for :self
    #
    #   embeds_many :employees
    #   custom_fields_for :employees
    # end
    #
    # class Employee
    #    embedded_in :company, :inverse_of => :employees
    #    field :name, String
    # end
    #
    # company.employee_custom_fields.build :label => 'His/her position', :_alias => 'position', :kind => 'string'
    #
    # company.employees.build :name => 'Michael Scott', :position => 'Regional manager'
    #
    #
    # company.self_custom_fields.build :label => 'Shipping Address', :_alias => 'address', :kind => 'text'
    #
    # company.metadata.address = '700 S Laflin, 60607 Chicago'
    #
    # other_company.metadata.address # returns a "not defined method" error
    #
    module ClassMethods

      def custom_fields_for(collection_name)
        singular_name = collection_name.to_s.singularize

        # generate the custom field for the couple defined by the class and the collection name
        dynamic_custom_field_class_name = "#{self.name}#{singular_name.camelize}Field"

        unless Object.const_defined?(dynamic_custom_field_class_name)
          (klass = Class.new(::CustomFields::Field)).class_eval <<-EOF
            embedded_in :#{self.name.underscore}, :inverse_of => :#{singular_name}_custom_fields
          EOF

          Object.const_set(dynamic_custom_field_class_name, klass)
        end

        # enhance the class itself
        if (itself = %w(itself self).include?(collection_name.to_s))
          collection_name, singular_name = '_metadata', 'metadata'

          class_eval <<-EOV
            embeds_one :#{collection_name}, :class_name => '::CustomFields::Metadata'

            def #{singular_name}
              self.#{collection_name} || self.build_#{collection_name}
            end

          EOV
        end

        # common part
        class_eval <<-EOV
          field :#{singular_name}_custom_fields_counter, :type => Integer, :default => 0

          embeds_many :#{singular_name}_custom_fields, :class_name => '#{dynamic_custom_field_class_name}'

          validates_associated :#{singular_name}_custom_fields

          after_validation do |record|
            if record.errors.empty?
              record.invalidate_#{singular_name}_klass
            end
          end
          after_destroy     :invalidate_#{singular_name}_klass

          accepts_nested_attributes_for :#{singular_name}_custom_fields, :allow_destroy => true

          def ordered_#{singular_name}_custom_fields
            self.#{singular_name}_custom_fields.sort { |a, b| (a.position || 0) <=> (b.position || 0) }
          end

          def fetch_#{singular_name}_klass
            metadata = self.relations['#{collection_name.to_s}']
            metadata.klass.to_klass_with_custom_fields(self.ordered_#{singular_name}_custom_fields, self, metadata.name)
          end

          def invalidate_#{singular_name}_klass
            metadata = self.relations['#{collection_name.to_s}']
            metadata.klass.invalidate_proxy_class_with_custom_fields(self, metadata.name)
          end
        EOV

        if itself
          class_eval <<-EOV
            alias :self_custom_fields :#{singular_name}_custom_fields
          EOV
        end

      end

    end

  end

end