# frozen_string_literal: true

module CustomFields
  module Types
    module Select
      class Option
        include Mongoid::Document

        field :name,      localize: true
        field :position,  type: ::Integer, default: 0

        embedded_in :custom_field, inverse_of: :select_options

        validates_presence_of :name

        def as_json(_options = nil)
          super methods: %w[_id name position]
        end
      end

      module Field
        extend ActiveSupport::Concern

        included do
          embeds_many :select_options, class_name: 'CustomFields::Types::Select::Option'

          validates_associated :select_options

          accepts_nested_attributes_for :select_options, allow_destroy: true
        end

        def ordered_select_options
          select_options.sort { |a, b| (a.position || 0) <=> (b.position || 0) }.to_a
        end

        def select_to_recipe
          {
            'select_options' => ordered_select_options.map do |option|
              { '_id' => option._id, 'name' => option.name_translations }
            end
          }
        end

        def select_as_json(_options = {})
          { 'select_options' => ordered_select_options.map(&:as_json) }
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
            name = rule['name']
            base_collection_name = "#{rule['name']}_options".to_sym

            klass.field :"#{name}_id", type: BSON::ObjectId, localize: rule['localized'] || false, default: lambda {
                                                                                                              _set_select_option(name, rule['default'])
                                                                                                            }

            klass.cattr_accessor "_raw_#{base_collection_name}"
            klass.send :"_raw_#{base_collection_name}=", rule['select_options'].sort { |a, b|
                                                           a['position'] <=> b['position']
                                                         }

            # other methods
            klass.send(:define_method, name.to_sym) { _get_select_option(name) }
            klass.send(:define_method, :"#{name}=") { |value| _set_select_option(name, value) }

            klass.class_eval <<-EOV, __FILE__, __LINE__ + 1

              def self.#{base_collection_name}
                self._select_options('#{name}')
              end

            EOV

            return unless rule['required']

            klass.validates_presence_of name
          end

          # Build a hash storing the values (id and option name) for
          # a select custom field of an instance.
          #
          # @param [ Object ] instance An instance of the class enhanced by the custom_fields
          # @param [ String ] name The name of the select custom field
          #
          # @return [ Hash ] fields: <name>: option name, <name>_id: id of the option
          #
          def select_attribute_get(instance, name)
            if value = instance.send(name.to_sym)
              {
                name => value,
                "#{name}_id" => instance.send(:"#{name}_id")
              }
            else
              {}
            end
          end

          # Set the value for the instance and the select field specified by
          # the 2 params.
          #
          # @param [ Object ] instance An instance of the class enhanced by the custom_fields
          # @param [ String ] name The name of the select custom field
          # @param [ Hash ] attributes The attributes used to fetch the values
          #
          def select_attribute_set(instance, name, attributes)
            id_or_name = attributes[name] || attributes["#{name}_id"]

            return if id_or_name.nil?

            option = _select_options(name).detect do |option|
              [option['_id'], option['name']].include?(id_or_name)
            end

            instance.send(:"#{name}_id=", option.try(:[], '_id'))
          end

          # Returns a list of documents groupes by select values defined in the custom fields recipe
          #
          # @param  [ Class ] klass The class to modify
          # @return [ Array ] An array of hashes (keys: select option and related documents)
          #
          def group_by_select_option(name, order_by = nil)
            name_id = "#{name}_id"
            groups = each.group_by { |x| x.send(name_id) }.map do |(k, v)|
              { name_id => k, 'group' => v }
            end

            _select_options(name).map do |option|
              group = groups.detect { |g| g[name_id].to_s == option['_id'].to_s }
              list  = group ? group['group'] : []

              groups.delete(group) if group

              { name: option['name'], entries: _order_select_entries(list, order_by) }.with_indifferent_access
            end.tap do |array|
              unless groups.empty? # orphan entries ?
                empty = { name: nil, entries: [] }.with_indifferent_access
                groups.each do |group|
                  empty[:entries] += group['group']
                end
                empty[:entries] = _order_select_entries(empty[:entries], order_by)
                array << empty
              end
            end
          end

          def _select_options(name)
            send(:"_raw_#{name}_options").map do |option|
              locale = Mongoid::Fields::I18n.locale.to_s

              name = if !option['name'].respond_to?(:merge)
                       option['name']
                     elsif option['name'].key?(locale)
                       option['name'][locale.to_s]
                     elsif Mongoid::Fields::I18n.fallbacks?
                       option['name'][Mongoid::Fields::I18n.fallbacks[locale.to_sym].map(&:to_s).find do |loc|
                                        !option['name'][loc].nil?
                                      end]
                     end

              { '_id' => option['_id'], 'name' => name }
            end
          end

          def _order_select_entries(list, order_by = nil)
            return list if order_by.nil?

            column, direction = order_by.flatten

            list = list.sort do |a, b|
              a.send(column) && b.send(column) ? (a.send(column) || 0) <=> (b.send(column) || 0) : 0
            end

            direction == 'asc' ? list : list.reverse

            list
          end
        end

        def _select_option_id(name)
          send(:"#{name}_id")
        end

        def _find_select_option(name, id_or_name)
          self.class._select_options(name).detect do |option|
            option['name'] == id_or_name || option['_id'].to_s == id_or_name.to_s
          end
        end

        def _get_select_option(name)
          option = _find_select_option(name, _select_option_id(name))
          option ? option['name'] : nil
        end

        def _set_select_option(name, value)
          option = _find_select_option(name, value)
          send(:"#{name}_id=", option ? option['_id'] : nil)
        end
      end
    end
  end
end
