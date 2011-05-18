module CustomFields
  module Types
    module HasMany

      extend ActiveSupport::Concern

      included do
        field :target

        validates_presence_of :target, :if => :has_many?

        register_type :has_many, Array
      end

      module InstanceMethods

        def apply_has_many_type(klass)
          klass.class_eval <<-EOF

            before_save :store_#{self.safe_alias.singularize}_ids

            def #{self.safe_alias}=(ids_or_objects)
              if @_#{self._name}.nil?
                @_#{self._name} = ProxyCollection.new('#{self.target.to_s}'.constantize, ids_or_objects)
              else
                @_#{self._name}.update(ids_or_objects)
              end
            end

            def #{self.safe_alias}
              @_#{self._name} ||= ProxyCollection.new('#{self.target.to_s}'.constantize, read_attribute(:#{self._name}))
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

      class ProxyCollection

        attr_accessor :target_klass, :ids, :values

        def initialize(target_klass, array = [])
          self.target_klass = target_klass
          self.update(array || [])
        end

        def find(id)
          id = BSON::ObjectId(id) unless id.is_a?(BSON::ObjectId)
          self.values.detect { |obj_id| obj_id == id }
        end

        def update(values)
          self.ids = values.collect { |obj| self.id_for_sure(obj) }
          self.values = values.collect { |obj| self.object_for_sure(obj) }
        end

        def <<(*args)
          args.flatten.compact.each do |obj|
            self.ids << self.id_for_sure(obj)
            self.values << self.object_for_sure(obj)
          end
        end

        alias :push :<<

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
              self.target_klass._parent.send(self.target_klass.association_name).find(id_or_object)
            else
              self.target_klass.find(id_or_object)
            end
          end
        end

      end

    end
  end
end