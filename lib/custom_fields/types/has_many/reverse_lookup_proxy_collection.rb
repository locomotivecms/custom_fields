module CustomFields
  module Types
    module HasMany

      class ReverseLookupProxyCollection < ProxyCollection

        attr_accessor :reverse_lookup_field, :previous_state

        def initialize(parent, target_klass, field_name, options = {})
          super

          self.reverse_lookup_field = options[:reverse_lookup_field].to_sym

          if self.parent.new_record?
            self.previous_state = { :ids => [], :values => [] }
          else
            self.reload
          end
        end

        def store_values
          true # do nothing
        end

        def persist
          (self.previous_state[:values] - self.values).each do |object|
            self.set_foreign_key_and_position(object, nil)
          end

          self.values.each_with_index do |object, position|
            self.set_foreign_key_and_position(object, self.parent._id, position)
          end

          if self.target_klass.embedded?
            self.target_klass._parent.save!(:validate => false)
          end

          self.reorder # update positions in the internal collection (self.values)

          self.reset_previous_state
        end

        def <<(id_or_object)
          object = self.object_for_sure(id_or_object)

          foreign_key = object.send(self.reverse_lookup_field)

          if foreign_key && foreign_key != self.parent._id
            raise ArgumentError, "Object #{object} cannot be added: already has a different foreign key"
          end

          self.ids << self.id_for_sure(object._id)
          self.values << self.object_for_sure(object)
        end

        def reload
          self.update(self.reverse_collection(true))

          self.reset_previous_state
        end

        protected

        def reverse_collection(reload = false)
          self.collection(reload).where(self.reverse_lookup_field => self.parent._id).order_by([[:"#{self.reverse_lookup_field}_position", :asc]])
        end

        def reorder
          self.values.sort! { |a, b| a.send(:"#{self.reverse_lookup_field}_position") <=> b.send(:"#{self.reverse_lookup_field}_position") }
        end

        def set_foreign_key_and_position(object, value, position = nil)
          objects = [object]

          if self.target_klass.embedded?
            # Fixme (Did): objects in self.values are different from the ones in self.collection
            objects << self.collection.find(object._id)
          end

          objects.each do |o|
            o.send("#{self.reverse_lookup_field}=".to_sym, value)
            o.send("#{self.reverse_lookup_field}_position=".to_sym, position)
          end

          unless self.target_klass.embedded?
            object.save(:validate => false)
          end
        end

        def reset_previous_state
          self.previous_state = {
            :ids    => self.ids.clone,
            :values => self.values.clone
          }
        end

      end

    end
  end
end
