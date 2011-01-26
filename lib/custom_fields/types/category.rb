module CustomFields
  module Types
    module Category

      extend ActiveSupport::Concern

      included do
        embeds_many :category_items, :class_name => 'CustomFields::Types::Category::Item'

        validates_associated :category_items

        accepts_nested_attributes_for :category_items, :allow_destroy => true

        register_type :category, BSON::ObjectId
      end

      module InstanceMethods

        def ordered_category_items
          self.category_items.sort { |a, b| (a.position || 0) <=> (b.position || 0) }
        end

        def category_names
          self.category_items.collect(&:name)
        end

        def category_ids
          self.category_items.collect(&:_id)
        end

        def apply_category_type(klass)
          klass.class_eval <<-EOF

            def self.#{self.safe_alias}_items
              self.lookup_custom_field('#{self._name}').ordered_category_items
            end

            def self.#{self.safe_alias}_names
              self.#{self.safe_alias}_items.collect(&:name)
            end

            def self.group_by_#{self.safe_alias}(list_method = nil)
              groups = (if self.embedded?
                list_method ||= self.association_name
                self._parent.send(list_method)
              else
                list_method ||= :all
                self.send(list_method)
              end).to_a.group_by(&:#{self._name})

              self.#{self.safe_alias}_items.collect do |category|
                {
                  :name   => category.name,
                  :items  => groups[category._id] || []
                }.with_indifferent_access
              end
            end

            def #{self.safe_alias}=(id)
              category = self.class.#{self.safe_alias}_items.find { |item| item.name == id || item._id.to_s == id.to_s }
              category_id = category ? category._id : nil
              write_attribute(:#{self._name}, category_id)
            end

            def #{self.safe_alias}
              category_id = read_attribute(:#{self._name})
              category = self.class.#{self.safe_alias}_items.find { |item| item._id == category_id }
              category ? category.name : nil
            end
          EOF
        end

      end

      class Item

        include Mongoid::Document

        field :name
        field :position, :type => Integer, :default => 0

        embedded_in :custom_field, :inverse_of => :category_items

        validates_presence_of :name
      end
    end
  end
end