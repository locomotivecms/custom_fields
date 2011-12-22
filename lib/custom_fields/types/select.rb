module CustomFields

  module Types

    module Select

      class Option

        include Mongoid::Document

        field :name
        field :position, :type => Integer, :default => 0

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

        module InstanceMethods

          def ordered_select_options
            self.select_options.sort { |a, b| (a.position || 0) <=> (b.position || 0) }.to_a
          end

          def select_to_recipe
            {
              'select_options' => self.ordered_select_options.map do |option|
                { '_id' => option._id, 'name' => option.name }
              end
            }
          end

          def select_as_json(options = {})
            { 'select_options' => self.ordered_select_options.map(&:as_json) }
          end

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
            name, collection_name = rule['name'], "_#{rule['name']}_options".to_sym

            klass.field :"#{name}_id", :type => BSON::ObjectId

            klass.cattr_accessor collection_name
            klass.send :"#{collection_name}=", rule['select_options']

            # other methods
            klass.send(:define_method, name.to_sym) { _get_select_option(name) }
            klass.send(:define_method, :"#{name}=") { |value| _set_select_option(name, value) }

            if rule['required']
              klass.validates_presence_of name
            end
          end

          # Returns a list of documents groupes by select values defined in the custom fields recipe
          #
          # @param [ Class ] klass The class to modify
          # @return [ Array ] An array of hashes (keys: select option and related documents)
          #
          def group_by_select_option(name)
            groups = self.only(:"#{name}_id").group

            _select_options(name).map do |option|
              group = groups.detect { |g| g["#{name}_id"].to_s == option['_id'].to_s }
              list  = group ? group['group'] : []
              { :name => option['name'], :items => list }.with_indifferent_access
            end
          end

          def _select_options(name)
            self.send(:"_#{name}_options")
          end

        end

        module InstanceMethods

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

end