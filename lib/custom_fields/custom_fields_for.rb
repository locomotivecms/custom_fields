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

        if (itself = %w(itself self).include?(collection_name.to_s))
          singular_name = '_metadata'

          class_eval <<-EOV
            embeds_one :#{singular_name}, :class_name => '::CustomFields::Metadata'

            def metadata
              self.#{singular_name} || self.build_#{singular_name}
            end

          EOV
        end

        class_eval <<-EOV
          field :#{singular_name}_custom_fields_counter, :type => Integer, :default => 0

          embeds_many :#{singular_name}_custom_fields, :class_name => '::CustomFields::Field'

          validates_associated :#{singular_name}_custom_fields

          accepts_nested_attributes_for :#{singular_name}_custom_fields, :allow_destroy => true

          def ordered_#{singular_name}_custom_fields
            self.#{singular_name}_custom_fields.sort { |a, b| (a.position || 0) <=> (b.position || 0) }
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