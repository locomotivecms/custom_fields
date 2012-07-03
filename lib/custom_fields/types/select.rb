module CustomFields

  module Types

    module Select

      class Option

        include Mongoid::Document

        field :name,      :localize => true
        field :position,  :type => Integer, :default => 0

        embedded_in :custom_field, :inverse_of => :select_options

        validates_presence_of :name

        def as_json(options = nil)
          super :methods => %w(_id name position)
        end

      end

      module Field

        extend ActiveSupport::Concern

        included do

          embeds_many :select_options, :class_name => 'CustomFields::Types::Select::Option'

          validates_associated :select_options

          accepts_nested_attributes_for :select_options, :allow_destroy => true

        end

        def ordered_select_options
          self.select_options.sort { |a, b| (a.position || 0) <=> (b.position || 0) }.to_a
        end

        def select_to_recipe
          {
            'select_options' => self.ordered_select_options.map do |option|
              { '_id' => option._id, 'name' => option.name_translations }
            end
          }
        end

        def select_as_json(options = {})
          { 'select_options' => self.ordered_select_options.map(&:as_json) }
        end

      end

      module Target

        extend ActiveSupport::Concern

        module ClassMethods

          # Adds a select field
          #
          # @param [ Class ] klass The class to modify
          # @param [ Hash ] rule It contains the name of the field and if it is required or not
          #
          def apply_select_custom_field(klass, rule)
            name, base_collection_name = rule['name'], "#{rule['name']}_options".to_sym

            klass.field :"#{name}_id", :type => BSON::ObjectId, :localize => rule['localized'] || false

            klass.cattr_accessor "_raw_#{base_collection_name}"
            klass.send :"_raw_#{base_collection_name}=", rule['select_options'].sort { |a, b| a['position'] <=> b['position'] }

            # other methods
            klass.send(:define_method, name.to_sym) { _get_select_option(name) }
            klass.send(:define_method, :"#{name}=") { |value| _set_select_option(name, value) }

            klass.class_eval <<-EOV

              def self.#{base_collection_name}
                self._select_options('#{name}')
              end

            EOV

            if rule['required']
              klass.validates_presence_of name
            end
          end

          # Returns a list of documents groupes by select values defined in the custom fields recipe
          #
          # @param [ Class ] klass The class to modify
          # @return [ Array ] An array of hashes (keys: select option and related documents)
          #
          def group_by_select_option(name, order_by = nil)
            groups = self.only(:"#{name}_id").group

            _select_options(name).map do |option|
              group = groups.detect { |g| g["#{name}_id"].to_s == option['_id'].to_s }
              list  = group ? group['group'] : []

              groups.delete(group) if group

              { :name => option['name'], :entries => self._order_select_entries(list, order_by) }.with_indifferent_access
            end.tap do |array|
              if not groups.empty? # orphan entries ?
                empty = { :name => nil, :entries => [] }.with_indifferent_access
                groups.each do |group|
                  empty[:entries] += group['group']
                end
                empty[:entries] = self._order_select_entries(empty[:entries], order_by)
                array << empty
              end
            end
          end

          def _select_options(name)
            self.send(:"_raw_#{name}_options").map do |option|

              locale = Mongoid::Fields::I18n.locale.to_s

              name = if !option['name'].respond_to?(:merge)
                option['name']
              elsif Mongoid::Fields::I18n.fallbacks?
                option['name'][Mongoid::Fields::I18n.fallbacks[locale.to_sym].map(&:to_s).find { |loc| !option['name'][loc].nil? }]
              else
                option['name'][locale.to_s]
              end

              { '_id' => option['_id'], 'name' => name }
            end
          end

          def _order_select_entries(list, order_by = nil)
            return list if order_by.nil?

            column, direction = order_by.flatten

            list = list.sort { |a, b| (a.send(column) && b.send(column)) ? (a.send(column) || 0) <=> (b.send(column) || 0) : 0 }

            direction == 'asc' ? list : list.reverse

            list
          end

        end

        def _select_option_id(name)
          self.send(:"#{name}_id")
        end

        def _find_select_option(name, id_or_name)
          self.class._select_options(name).detect do |option|
            option['name'] == id_or_name || option['_id'].to_s == id_or_name.to_s
          end
        end

        def _get_select_option(name)
          option = self._find_select_option(name, self._select_option_id(name))
          option ? option['name'] : nil
        end

        def _set_select_option(name, value)
          option = self._find_select_option(name, value)
          self.send(:"#{name}_id=", option ? option['_id'] : nil)
        end

      end

    end

  end

end