module CustomFields
  module Types
    module Tags
      module Field; end
      
      module Target
        extend ActiveSupport::Concern
        
        module ClassMethods

          def apply_tags_custom_field(klass, rule)
            klass.field rule['name'], localize: rule['localized'] || false, type: Array
            
            klass.class_eval do
              define_method("#{rule['name']}=") do |val|
                #FIXME I would use is_a?(), but it doesn't work in my machine!
                val = val.split(/ *, */) if val.class.to_s == "String" 
                super(val)
              end
            end
          end
          
          def tags_attribute_get(instance, name)
            self.default_attribute_get(instance, name)
          end

          def tags_attribute_set(instance, name, attributes)
            self.default_attribute_set(instance, name, attributes)
          end
        end
      end
      
    end
  end
end