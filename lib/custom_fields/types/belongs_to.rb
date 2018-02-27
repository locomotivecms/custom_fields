module CustomFields

  module Types

    module BelongsTo

      module Field

        extend ActiveSupport::Concern

        included do

          def belongs_to_to_recipe
            { 'class_name' => self.class_name, 'inverse_of' => self.inverse_of }
          end

          def belongs_to_is_relationship?
            self.type == 'belongs_to'
          end

        end

      end

      module Target

        extend ActiveSupport::Concern

        module ClassMethods

          # Adds a belongs_to relationship between 2 models
          #
          # @param [ Class ] klass The class to modify
          # @param [ Hash ] rule It contains the name of the field and if it is required or not
          #
          def apply_belongs_to_custom_field(klass, rule)
            # puts "#{klass.inspect}.belongs_to #{rule['name'].inspect}, class_name: #{rule['class_name'].inspect}" # DEBUG

            position_name = "position_in_#{rule['name'].underscore}"

            # puts "#{klass.inspect}.field :#{position_name}" # DEBUG

            klass.field position_name, type: ::Integer, default: 0

            options = { class_name: rule['class_name'], optional: true }
            options[:inverse_of] = rule['inverse_of'] unless rule['inverse_of'].blank? # an empty String can cause weird behaviours

            klass.belongs_to rule['name'].to_sym, options

            if rule['required']
              klass.validates_presence_of rule['name'].to_sym
            end

            klass.before_create do |object|
              position = (object.class.max(position_name.to_sym) || 0) + 1
              object.send(:"#{position_name}=", position)
            end
          end

        end

      end

    end

  end

end
