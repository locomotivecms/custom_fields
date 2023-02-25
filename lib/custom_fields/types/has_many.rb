# frozen_string_literal: true

module CustomFields
  module Types
    module HasMany
      module Field
        extend ActiveSupport::Concern

        included do
          def has_many_to_recipe
            { 'class_name' => class_name, 'inverse_of' => inverse_of, 'order_by' => order_by }
          end

          def has_many_is_relationship?
            type == 'has_many'
          end
        end
      end

      module Target
        extend ActiveSupport::Concern
        module ClassMethods
          # Adds a has_many relationship between 2 mongoid models
          #
          # @param [ Class ] klass The class to modify
          # @param [ Hash ] rule It contains the name of the relation and if it is required or not
          #
          def apply_has_many_custom_field(klass, rule)
            # puts "#{klass.inspect}.has_many #{rule['name'].inspect}, class_name: #{rule['class_name'].inspect}, inverse_of: #{rule['inverse_of']}, order_by: #{rule['order_by'].inspect}" # DEBUG
            position_name = "position_in_#{rule['inverse_of']}"

            _order_by   = rule['order_by'] || position_name.to_sym.asc
            _inverse_of = rule['inverse_of'].blank? ? nil : rule['inverse_of'] # an empty String can cause weird behaviours

            klass.has_many rule['name'], class_name: rule['class_name'], inverse_of: _inverse_of, order: _order_by,
                                         validate: false do
              def filtered(conditions = {}, order_by = nil)
                list = conditions.empty? ? unscoped : where(conditions)

                list.order_by(order_by || association.options[:order])
              end
              alias_method :ordered, :filtered # backward compatibility + semantic purpose
            end

            klass.accepts_nested_attributes_for rule['name'], allow_destroy: true

            return unless rule['required']

            klass.validates_collection_size_of rule['name'], minimum: 1, message: :at_least_one_element, on: :update
          end
        end
      end
    end
  end
end
