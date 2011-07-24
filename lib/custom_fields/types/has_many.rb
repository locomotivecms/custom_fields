module CustomFields
  module Types
    module HasMany

      extend ActiveSupport::Concern

      included do
        field :target
        field :reverse_lookup

        validates_presence_of :target, :if => :has_many?

        register_type :has_many, Array
      end

      module InstanceMethods

        def apply_has_many_type(klass)
          # If it's a reverse_lookup, only provide readonly access
          if self.reverse_lookup && !self.reverse_lookup.strip.blank?

            klass.class_eval <<-EOF

              def #{self.safe_alias}
                @_#{self._name} ||= ReverseLookupProxyCollection.new('#{self.target.to_s}', '#{self.reverse_lookup}', self._id)
              end

              def #{self.safe_alias}=(objects)
                self.#{self.safe_alias}.update(objects)
              end
            EOF
          else
            klass.class_eval <<-EOF

              before_validation :store_#{self.safe_alias.singularize}_ids

              def #{self.safe_alias}=(ids_or_objects)
                if @_#{self._name}.nil?
                  @_#{self._name} = ProxyCollection.new('#{self.target.to_s}', ids_or_objects)
                else
                  @_#{self._name}.update(ids_or_objects)
                end
              end

              def #{self.safe_alias}
                @_#{self._name} ||= ProxyCollection.new('#{self.target.to_s}', read_attribute(:#{self._name}))
              end

              def #{self.safe_alias.singularize}_ids
                self.#{self.safe_alias}.ids
              end

              def store_#{self.safe_alias.singularize}_ids
                write_attribute(:#{self._name}, #{self.safe_alias.singularize}_ids)
              end
            EOF
          end
        end

        def add_has_many_validation(klass)
          if self.required?
            klass.validates_length_of self.safe_alias.to_sym, :minimum => 1, :too_short => :blank
          end
        end

      end

      class ProxyCollection

        attr_accessor :target_klass, :ids, :values

        def initialize(target_klass_name, array = [])
          self.target_klass = target_klass_name.constantize rescue nil

          array = [] if self.target_klass.nil?

          self.update(array || [])
        end

        def find(id)
          id = BSON::ObjectId(id) unless id.is_a?(BSON::ObjectId)
          self.values.detect { |obj_id| obj_id == id }
        end

        def update(values)
          values = [] if values.blank?

          self.ids = values.collect { |obj| self.id_for_sure(obj) }.compact
          self.values = values.collect { |obj| self.object_for_sure(obj) }.compact
        end

        def <<(*args)
          args.flatten.compact.each do |obj|
            self.ids << self.id_for_sure(obj)
            self.values << self.object_for_sure(obj)
          end
        end

        alias :push :<<

        def size
          self.values.size
        end

        alias :length :size

        def method_missing(name, *args, &block)
          self.values.send(name, *args, &block)
        end

        protected

        def id_for_sure(id_or_object)
          id_or_object.respond_to?(:_id) ? id_or_object._id : id_or_object
        end

        def object_for_sure(id_or_object)
          if id_or_object.respond_to?(:_id)
            id_or_object
          else
            if self.target_klass.embedded?
              self.target_klass._parent.reload.send(self.target_klass.association_name).find(id_or_object)
            else
              self.target_klass.find(id_or_object)
            end
          end
        rescue # target_klass does not exist anymore or the target element has been removed since
          nil
        end

      end

      # TODO shared code in initialize and find
      class ReverseLookupProxyCollection

        attr_accessor :target_klass, :reverse_lookup_field, :owner_id

        def initialize(target_klass_name, reverse_lookup_field, owner_id)
          self.target_klass = target_klass_name.constantize rescue nil

          self.reverse_lookup_field = reverse_lookup_field
          self.owner_id = owner_id
        end

        def values
          arr = []
          objects do |obj|
            arr << obj
          end
          return arr
        end

        def ids
          arr = []
          objects do |obj|
            arr << obj._id
          end
          return arr
        end

        def find(id)
          id = BSON::ObjectId(id) unless id.is_a?(BSON::ObjectId)
          self.values.detect { |obj_id| obj_id == id }
        end

        def <<(obj)
          # TODO should we make sure it's the right type?

          # Check the owner id of the object to be added
          obj_owner = obj.send(reverse_lookup_field.to_sym)
          obj_owner_id = obj_owner._id if obj_owner
          if obj_owner && obj_owner_id != owner_id
            raise ArgumentError, "Object #{obj} cannot be added: already has an owner"
          end

          obj.send("#{reverse_lookup_field}=".to_sym, owner_id)
        end

        def clear!
          ret = []
          objects do |obj|
            obj.send("#{self.reverse_lookup_field}=".to_sym, nil)

            # TODO: May not want to save them...may want the caller to do that
            obj.save!
          end
        end

        def update(values)
          self.clear!
          values.each do |obj|
            # Reload the object as it may have been changed
            if obj.embedded?
              obj = obj._parent.reload.send(obj.association_name).find(obj._id)
            else
              obj.reload
            end

            self << obj

            # TODO: as above, may not want to save them here...
            obj.save!
          end
        end

        def size
          self.values.size
        end

        alias :length :size

        def empty?
          self.values.empty?
        end

        protected

        # TODO this is inefficient! Should translate the "reverse_lookup"
        # string to a string like 'custom_field_#' and let mongo find the
        # targets
        def objects
          if self.target_klass.embedded?
            klass = self.target_klass._parent.reload.send(self.target_klass.association_name)
          else
            klass = self.target_klass
          end

          # TODO don't want to do `each': won't work if we hit the `else'
          # statement above
          klass.each do |obj|
            reverse_lookup_field_val = obj.send(self.reverse_lookup_field)
            if reverse_lookup_field_val && reverse_lookup_field_val._id == self.owner_id
              yield obj
            end
          end
        end
      end

    end
  end
end
