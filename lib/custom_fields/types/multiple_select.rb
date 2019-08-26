module CustomFields

  module Types

    module MultipleSelect

      class Option

        include Mongoid::Document

        field :name,      localize: true
        field :position,  type: ::Integer, default: 0

        embedded_in :custom_field, inverse_of: :multiple_select_options

        validates_presence_of :name

        def as_json(options = nil)
          super methods: %w(_id name position)
        end

      end

      module Field

        extend ActiveSupport::Concern

        AVAILABLE_APPEARANCE_TYPES = %w(checkbox select_multiple)

        included do
          embeds_many :multiple_select_options, class_name: 'CustomFields::Types::MultipleSelect::Option'

          validates_associated :multiple_select_options

          accepts_nested_attributes_for :multiple_select_options, allow_destroy: true
        end

        def ordered_multiple_select_options
          self.multiple_select_options.sort { |a, b| (a.position || 0) <=> (b.position || 0) }.to_a
        end

        def multiple_select_to_recipe
          {
            'multiple_select_options' => self.ordered_multiple_select_options.map do |option|
              { '_id' => option._id, 'name' => option.name_translations }
            end
          }
        end

        def multiple_select_as_json(options = {})
          { 'multiple_select_options' => self.ordered_multiple_select_options.map(&:as_json) }
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
          def apply_multiple_select_custom_field(klass, rule)
            name, base_collection_name = rule['name'], "#{rule['name']}_options".to_sym

            klass.field :"#{name}_ids", type: Array, localize: rule['localized'] || false, default: ->{ _set_multiple_select_option(name, rule['default']) }
            klass.cattr_accessor "_raw_#{base_collection_name}"
            klass.send :"_raw_#{base_collection_name}=", rule['multiple_select_options'].sort { |a, b| a['position'] <=> b['position'] }

            # other methods
            klass.send(:define_method, name.to_sym) { _get_multiple_select_option(name) }
            klass.send(:define_method, :"#{name}=") { |value| _set_multiple_select_option(name, value) }
            klass.send(:define_method, :"#{name}_ids=") { |value| _set_multiple_select_option(name, value) }

            klass.class_eval <<-EOV

              def self.#{base_collection_name}
                self._multiple_select_options('#{name}')
              end

            EOV

            if rule['required']
              klass.validates_presence_of name
            end
          end

          # Build a hash storing the values (id and option name) for
          # a select custom field of an instance.
          #
          # @param [ Object ] instance An instance of the class enhanced by the custom_fields
          # @param [ String ] name The name of the select custom field
          #
          # @return [ Hash ] fields: <name>: option name, <name>_id: id of the option
          #
          def multiple_select_attribute_get(instance, name)
            value = instance.send(name.to_sym)
            if value.present?
              {
                name          => value,
                "#{name}_ids"  => instance.send(:"#{name}_ids")
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
          def multiple_select_attribute_set(instance, name, attributes)
            ids_or_names  = attributes[name] || attributes["#{name}_ids"]

            return if ids_or_names.nil?

            options = _multiple_select_options(name).select do |option|
              ids_or_names.include?(option['name']) || ids_or_names.map(&:to_s).include?(option['_id'].to_s)
            end.map{|opt| opt['_id']}

            instance.send(:"#{name}_ids=", options)
          end

          def _multiple_select_options(name)
            self.send(:"_raw_#{name}_options").map do |option|

              locale = Mongoid::Fields::I18n.locale.to_s

              name = if !option['name'].respond_to?(:merge)
                option['name']
              elsif option['name'].has_key?(locale)
                option['name'][locale.to_s]
              elsif Mongoid::Fields::I18n.fallbacks?
                option['name'][Mongoid::Fields::I18n.fallbacks[locale.to_sym].map(&:to_s).find { |loc| !option['name'][loc].nil? }]
              else
                nil
              end

              { '_id' => option['_id'], 'name' => name }
            end
          end

          def _order_multiple_select_entries(list, order_by = nil)
            return list if order_by.nil?

            column, direction = order_by.flatten

            list = list.sort { |a, b| (a.send(column) && b.send(column)) ? (a.send(column) || 0) <=> (b.send(column) || 0) : 0 }

            direction == 'asc' ? list : list.reverse

            list
          end

        end

        def _multiple_select_option_ids(name)
          self.send(:"#{name}_ids")
        end

        def _find_multiple_select_option(name, id_or_name)
          self.class._multiple_select_options(name).detect do |option|
            option['name'] == id_or_name || option['_id'].to_s == id_or_name.to_s
          end
        end

        def _find_multiple_select_options(name, ids_or_names)
          self.class._multiple_select_options(name).select do |option|
            ids_or_names.include?(option['name']) || ids_or_names.map(&:to_s).include?(option['_id'].to_s)
          end
        end

        def _get_multiple_select_option(name)
          options = self._find_multiple_select_options(name, self._multiple_select_option_ids(name))
          options.map {|option| option['name'] }
        end

        def _set_multiple_select_option(name, values)
          values = [] if values.nil?
          raise ArgumentError, 'invalid values(accepts only array of string or BSON id)' unless values.is_a?(Array)

          option_ids = self._find_multiple_select_options(name, values).map{|opt| opt['_id']}

          self.send(:write_attribute, :"#{name}_ids", option_ids)
      end

    end

  end

end
