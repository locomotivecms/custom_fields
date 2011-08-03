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

        def reverse_has_many?
          self.reverse_lookup && !self.reverse_lookup.strip.blank?
        end

        def safe_reverse_lookup
          if self.reverse_lookup =~ /^custom_field_[0-9]+$/
            self.reverse_lookup
          else
            self.target.constantize.custom_field_alias_to_name(self.reverse_lookup)
          end
        end

        def apply_has_many_type(klass)
          klass.class_eval <<-EOF

            before_validation :store_#{self.safe_alias.singularize}_ids

            after_save :persist_#{self.safe_alias}

            def #{self.safe_alias}=(ids_or_objects)
              if @_#{self._name}.nil?
                @_#{self._name} = build_#{self.safe_alias.singularize}_proxy_collection(ids_or_objects)
              else
                @_#{self._name}.update(ids_or_objects)
              end
            end

            def #{self.safe_alias}
              @_#{self._name} ||= build_#{self.safe_alias.singularize}_proxy_collection(read_attribute(:#{self._name}))
            end

            def #{self.safe_alias.singularize}_ids
              self.#{self.safe_alias}.ids
            end

            def store_#{self.safe_alias.singularize}_ids
              self.#{self.safe_alias}.store_values
            end

            def persist_#{self.safe_alias}
              self.#{self.safe_alias}.persist
            end

          EOF

          if reverse_has_many?
            klass.class_eval <<-EOF
              def build_#{self.safe_alias.singularize}_proxy_collection(ids_or_objects)
                ::CustomFields::Types::HasMany::ReverseLookupProxyCollection.new(self, '#{self.target.to_s}', '#{self._name}', {
                  :array => ids_or_objects,
                  :reverse_lookup_field => '#{self.safe_reverse_lookup}'
                })
              end
            EOF
          else
            klass.class_eval <<-EOF
              def build_#{self.safe_alias.singularize}_proxy_collection(ids_or_objects)
                ::CustomFields::Types::HasMany::ProxyCollection.new(self, '#{self.target.to_s}', '#{self._name}', {
                  :array => ids_or_objects
                })
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

    end
  end
end
