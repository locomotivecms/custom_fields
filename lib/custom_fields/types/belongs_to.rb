module CustomFields

  module Types

    module BelongsTo

      module Field

        extend ActiveSupport::Concern

        included do

          field :class_name

          validates_presence_of :class_name, :if => Proc.new { |f| f.type == 'belongs_to' }

          def belongs_to_to_recipe
            { 'class_name' => self.class_name }
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
            # puts "#{klass.inspect}.belongs_to #{rule['name'].inspect}, :class_name => #{rule['class_name'].inspect}" # DEBUG

            klass.belongs_to rule['name'].to_sym, :class_name => rule['class_name']

            if rule['required']
              klass.validates_presence_of rule['name'].to_sym
            end

            # puts klass.associations.inspect
          end

        end

      end

    end

  end

end