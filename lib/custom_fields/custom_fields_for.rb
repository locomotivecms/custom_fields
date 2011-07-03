module CustomFields

  module CustomFieldsFor

    extend ActiveSupport::Concern

    included do
      cattr_accessor :_custom_fields_for

      self._custom_fields_for = []
    end

    module InstanceMethods

      def custom_fields_for?(collection_name)
        self.class.custom_fields_for?(collection_name)
      end

      def clone_metadata_for_custom_fields(metadata)
        singular_name = metadata.name.to_s.singularize.gsub(/^_/, '')

        klass = self.send(:"fetch_#{singular_name}_klass")

        # safer to do that because we are going to modify the metadata klass for next operations
        metadata.clone.tap do |metadata|
          metadata.instance_variable_set(:@klass, klass)
        end
      end

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

      def custom_fields_for?(collection_name)
        self._custom_fields_for.include?(collection_name.to_s)
      end

      def custom_fields_for(collection_name)
        singular_name                   = collection_name.to_s.singularize
        dynamic_custom_field_class_name = "#{self.name}#{singular_name.camelize}Field"

        self.declare_embedded_in_definition_in_custom_field(collection_name)

        # enhance the class itself
        if (itself = %w(itself self).include?(collection_name.to_s))
          collection_name, singular_name = '_metadata', 'metadata'

          class_eval <<-EOV
            embeds_one :#{collection_name}, :class_name => '::CustomFields::Metadata'

            def safe_#{singular_name}
              self.#{collection_name} || self.build_#{collection_name}
            end
          EOV
        end

        # record the collection_name
        self._custom_fields_for << collection_name.to_s

        # common part
        class_eval <<-EOV
          field :#{singular_name}_custom_fields_counter, :type => Integer, :default => 0
          field :#{singular_name}_custom_fields_version, :type => Integer, :default => 0

          embeds_many :#{singular_name}_custom_fields, :class_name => '#{dynamic_custom_field_class_name}' do
            def build(attributes = {}, type = nil, &block)
              instantiated(type).tap do |doc|
                append(doc, default_options(:binding => true))
                doc.write_attributes(attributes)
                doc.identify
                block.call(doc) if block
              end
            end
            alias :new :build
          end

          attr_accessor :invalidate_#{singular_name}_klass_flag

          before_save do |record|
            if record.invalidate_#{singular_name}_klass?
              record.#{singular_name}_custom_fields_version ||= 0
              record.#{singular_name}_custom_fields_version += 1
              # puts "[parent/before_save] set #{singular_name}_custom_fields_version " + record.#{singular_name}_custom_fields_version.to_s # debug purpose
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

          def #{singular_name}_klass
            metadata = self.relations['#{collection_name.to_s}']
            metadata.klass.current_klass_with_custom_fields(self, metadata.name)
          end

          def #{singular_name}_klass_out_of_date?
            self.#{singular_name}_klass.nil? || self.#{singular_name}_klass.version != self.#{singular_name}_custom_fields_version
          end

          def invalidate_#{singular_name}_klass
            metadata = self.relations['#{collection_name.to_s}']
            metadata.klass.invalidate_proxy_class_with_custom_fields(self, metadata.name)
          end

          def invalidate_#{singular_name}_klass?
            self.invalidate_#{singular_name}_klass_flag == true
          end
        EOV

        # mongoid tiny patch: for performance optimization (ie: we do want to invalidate klass with custom fields every time we save a field)
        unless instance_methods.collect(&:to_s).include?('write_attributes_with_custom_fields')

          class_eval do
            def write_attributes_with_custom_fields(attrs = nil, guard_protected_attributes = true)
              self.instance_variable_set(:@_writing_attributes_with_custom_fields, true)
              self.write_attributes_without_custom_fields(attrs, guard_protected_attributes)
            end

            alias_method_chain :write_attributes, :custom_fields
          end

        end

        if itself
          class_eval <<-EOV
            alias :self_custom_fields :#{singular_name}_custom_fields
          EOV
        end

      end

      protected

      def dynamic_custom_field_class_name(collection_name)
        "#{self.name}#{collection_name.to_s.singularize.camelize}Field"
      end

      # An embedded relationship has to be defined on both side in order for it
      # to work properly. But because custom_field can be embedded in different
      # models that it's not aware of, we have to declare manually the definition
      # once we know the target class.
      def declare_embedded_in_definition_in_custom_field(target_collection_name)
        singular_name   = target_collection_name.to_s.singularize
        klass_name      = self.dynamic_custom_field_class_name(target_collection_name)

        unless Object.const_defined?(klass_name)
          (klass = Class.new(::CustomFields::Field)).class_eval <<-EOF
            embedded_in :#{self.name.underscore}, :inverse_of => :#{singular_name}_custom_fields
          EOF

          Object.const_set(klass_name, klass)
        end
      end

    end

  end

end