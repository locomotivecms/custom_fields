module CustomFields

  module Types

    module HasMany

      module Field

        extend ActiveSupport::Concern

        included do

          def has_many_to_recipe
            { 'class_name' => self.class_name, 'inverse_of' => self.inverse_of, 'order_by' => self.order_by }
          end

          def has_many_is_relationship?
            self.type == 'has_many'
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
            # puts "#{klass.inspect}.has_many #{rule['name'].inspect}, :class_name => #{rule['class_name'].inspect}, :inverse_of => #{rule['inverse_of']}" # DEBUG

            position_name = "position_in_#{rule['inverse_of']}"

            _order_by = rule['order_by'] || position_name.to_sym.asc

            klass.has_many rule['name'], :class_name => rule['class_name'], :inverse_of => rule['inverse_of'], :order => _order_by do

              def filtered(conditions = {}, order_by = nil)
                list = conditions.empty? ? self : self.where(conditions)

                if order_by
                  list.order_by(order_by)
                else
                  # calling all on a has_many relationship makes us lose the default order_by (mongoid bug ?)
                  list.order(metadata.order)
                end
              end

              alias :ordered :filtered # backward compatibility + semantic purpose

            end

            klass.accepts_nested_attributes_for rule['name'], :allow_destroy => true

            if rule['required']
              klass.validates_length_of rule['name'], :minimum => 1
            end
          end

        end

      end

    end

  end

end