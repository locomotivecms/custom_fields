module CustomFields
  module Types
    module HasMany

      class ProxyCollection

        attr_accessor :parent, :target_klass, :field_name, :ids, :values

        def initialize(parent, target_klass_name, field_name, options = {})
          self.parent = parent

          self.target_klass = target_klass_name.constantize rescue nil

          self.field_name = field_name

          if options[:array]
            self.update(options[:array])
          else
            self.ids, self.values = [], []
          end
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

        # just before the parent gets saved, reflect the changes to the parent object
        def store_values
          self.parent.write_attribute(self.field_name, self.ids)
        end

        # once the parent object gets saved, call this method, kind of hook or callback
        def persist
          true
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
            self.collection.find(id_or_object)
          end
        rescue # target_klass does not exist anymore or the target element has been removed since
          nil
        end

        def collection(reload_embedded = false)
          if self.target_klass.embedded?
            parent_target_klass = self.target_klass._parent

            parent_target_klass = parent_target_klass.reload if reload_embedded

            parent_target_klass.send(self.target_klass.association_name)
          else
            self.target_klass
          end
        end

      end

    end
  end
end