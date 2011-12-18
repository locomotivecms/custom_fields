module CustomFields

  module Types

    module Category

      class Item

        include Mongoid::Document

        field :name
        field :position, :type => Integer, :default => 0

        embedded_in :custom_field, :inverse_of => :category_items

        validates_presence_of :name

        def as_json
          super :methods => %w(_id name position new_record? errors)
        end

      end

      module Field

        extend ActiveSupport::Concern

        included do

          embeds_many :category_items, :class_name => 'CustomFields::Types::Category::Item'

          validates_associated :category_items

          accepts_nested_attributes_for :category_items, :allow_destroy => true

        end

        module InstanceMethods

          def ordered_category_items
            self.category_items.sort { |a, b| (a.position || 0) <=> (b.position || 0) }
          end

          def category_to_recipe
            {
              'category_items' => self.ordered_category_items.map do |item|
                { '_id' => item._id, 'name' => item.name }
              end
            }
          end

        end

      end

      module Target

        extend ActiveSupport::Concern

        module ClassMethods

          # Adds a category field
          #
          # @param [ Class ] klass The class to modify
          # @param [ Hash ] rule It contains the name of the field and if it is required or not
          #
          def apply_category_custom_field(klass, rule)
            name, collection_name = rule['name'], "_#{rule['name']}_items".to_sym

            klass.field :"#{name}_id", :type => BSON::ObjectId

            klass.cattr_accessor collection_name
            klass.send :"#{collection_name}=", rule['category_items']

            # other methods
            klass.send(:define_method, name.to_sym) { _get_category(name) }
            klass.send(:define_method, :"#{name}=") { |value| _set_category(name, value) }

            if rule['required']
              klass.validates_presence_of name
            end
          end

          # Returns a list of documents groupes by categories defined in the custom fields recipe
          #
          # @param [ Class ] klass The class to modify
          # @return [ Array ] An array of hashes (keys: name and items)
          #
          def group_by_category(name)
            groups = self.only(:"#{name}_id").group

            _category_items(name).map do |category|
              group = groups.detect { |g| g["#{name}_id"].to_s == category['_id'].to_s }
              list  = group ? group['group'] : []
              { :name => category['name'], :items => list }.with_indifferent_access
            end
          end

          def _category_items(name)
            self.send(:"_#{name}_items")
          end

        end

        module InstanceMethods

          def _category_id(name)
            self.send(:"#{name}_id")
          end

          def _find_category(name, id_or_name)
            self.class._category_items(name).detect do |item|
              item['name'] == id_or_name || item['_id'].to_s == id_or_name.to_s
            end
          end

          def _get_category(name)
            item = self._find_category(name, self._category_id(name))
            item ? item['name'] : nil
          end

          def _set_category(name, value)
            item = self._find_category(name, value)
            self.send(:"#{name}_id=", item ? item['_id'] : nil)
          end

        end

      end

    end

  end

end