module CustomFields
  module Types
    module HasMany

      class ReverseLookupProxyCollection < ProxyCollection

        attr_accessor :reverse_lookup_field, :previous_state

        def initialize(parent, target_klass_name, field_name, options = {})
          array = options.delete(:array)

          # puts "[ReverseLookupProxyCollection] ....."

          super

          # puts "[ReverseLookupProxyCollection] .....super done"

          self.reverse_lookup_field = options[:reverse_lookup_field].to_sym

          unless self.parent.new_record?
            # puts "not a new record !"
            self.reload
          else
            self.previous_state = { :ids => [], :values => [] }
          end

          self.update(array)

          # self.reload

          # TODO: figure out what to do with options[:array]
          # unless self.parent.new_record?
          #   tmp_ids, tmp_values = self.ids, self.values
          #
          #   self.reload
          #
          #   self.ids, self.values = tmp_ids, tmp_values
          # end

          # self.update(options[:array]) if options.has_key?(:array)

          # puts "[ReverseLookupProxyCollection] initialized"
        end

        def store_values
          true # do nothing
        end

        def persist
          # puts "_____ persist ________"
          # puts "previous values = #{self.previous_state[:values].inspect}"
          # puts "values = #{self.values.inspect}"
          # puts "-----------"
          # puts "previous: #{self.previous_state[:values].collect(&:_id)}"
          # puts "current: #{self.values.collect(&:_id)}"

          (self.previous_state[:ids] - self.ids).each do |id|
            self.set_foreign_key(id, nil)
          end

          (self.ids - self.previous_state[:ids]).each do |id|
            self.set_foreign_key(id, self.parent._id)
          end

          # # unset the relationships for missing items
          # (self.values - self.previous_state[:values]).each do |object|
          #   # puts "[remove] #{object.class.inspect} / #{object.inspect} / #{self.reverse_lookup_field.inspect}"
          #
          #   object.send("#{self.reverse_lookup_field}=".to_sym, nil)
          #
          #   puts "[remove] #{object._id} (after) / #{self.target_klass.embedded?}"
          #
          #   object.save_with_validation(false) unless self.target_klass.embedded?
          # end

          # # set the relationships for new items
          # (self.previous_state[:values] - self.values).each do |object|
          #   object.send("#{self.reverse_lookup_field}=".to_sym, self.parent._id)
          #
          #   object.save_with_validation(false) unless self.target_klass.embedded?
          # end

          # if self.target_klass.embedded? && !self.values.empty?
          #   target_parent = self.values.first._parent
          #   puts "Saving the parent #{target_parent.inspect} / #{target_parent.employees.inspect}"
          #   target_parent.save!(:validate => false)
          # end

          if self.target_klass.embedded? # && !self.values.empty?
            # target_parent = self.values.first._parent
            # puts "Saving the parent #{target_parent.inspect} / #{target_parent.employees.inspect}"

            self.target_klass._parent.save!(:validate => false)

            # target_parent.save!(:validate => false)
          end

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
          self.update(self.reverse_collection)

          self.reset_previous_state

          # puts "[ReverseLookupProxyCollection] #{self.reset_previous_state.inspect}"
        end

        protected

        # def objects # rename into fetch_collection with cache ?
        #   # puts "self = #{self.parent.inspect}"
        #   # puts "self.target_klass = #{self.target_klass.inspect}"
        #   # puts "safe_target_klass = #{safe_target_klass.inspect}"
        #   # puts "where #{self.reverse_lookup_field.inspect} => #{self.parent._id.inspect}"
        #   self.collection(true).where(self.reverse_lookup_field => self.parent._id).all
        # end

        def reverse_collection
          self.collection.where(self.reverse_lookup_field => self.parent._id).tap do |c|
            # puts "collection = #{c.all.to_a.inspect}"
          end
        end

        def set_foreign_key(object_id, value)
          if self.target_klass.embedded?
            puts "[set_foreign_key / #{value}] retrieving #{object_id.inspect}"

            object = self.collection.find(object_id)

            puts "[set_foreign_key / #{value}] #{object.inspect}"

            object.send("#{self.reverse_lookup_field}=".to_sym, value)
          else
            object = self.previous_state[:values].detect { |o| o._id == object_id }
            object.send("#{self.reverse_lookup_field}=".to_sym, value)
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
