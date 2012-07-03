module CustomFields

  module Types

    module ManyToMany

      module Field

        extend ActiveSupport::Concern

        included do

          def many_to_many_to_recipe
            { 'class_name' => self.class_name, 'inverse_of' => self.inverse_of, 'order_by' => self.order_by }
          end

          def many_to_many_is_relationship?
            self.type == 'many_to_many'
          end

        end

      end

      module Target

        extend ActiveSupport::Concern

        module ClassMethods

          # Adds a many_to_many relationship between 2 mongoid models
          #
          # @param [ Class ] klass The class to modify
          # @param [ Hash ] rule It contains the name of the relation and if it is required or not
          #
          def apply_many_to_many_custom_field(klass, rule)
            # puts "#{klass.inspect}.many_to_many #{rule['name'].inspect}, :class_name => #{rule['class_name'].inspect} / #{rule['order_by']}" # DEBUG

            klass.has_and_belongs_to_many rule['name'], :class_name => rule['class_name'], :inverse_of => rule['inverse_of'], :order => rule['order_by'] do

              def filtered(conditions = {}, order_by = nil)
                list = conditions.empty? ? self : self.where(conditions)

                if order_by
                  list.order_by(order_by)
                else
                  # use the natural order given by the initial array (ex: project_ids).
                  # Warning: it returns an array and not a criteria object meaning it breaks the chain
                  ids = base.send(metadata.key.to_sym)
                  list.entries.sort { |a, b| ids.index(a.id) <=> ids.index(b.id) }
                end
              end

              alias :ordered :filtered # backward compatibility + semantic purpose

            end

            if rule['required']
              klass.validates_length_of rule['name'], :minimum => 1
            end
          end

        end

      end

    end

  end

end