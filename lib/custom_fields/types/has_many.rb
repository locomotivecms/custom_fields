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

        def target_klass
          self.target.constantize rescue nil
        end

        def reverse_has_many?
          self.reverse_lookup && !self.reverse_lookup.strip.blank?
        end

        def safe_reverse_lookup
          if self.reverse_lookup =~ /^custom_field_[0-9]+$/
            self.reverse_lookup
          else
            self.target_klass.custom_field_alias_to_name(self.reverse_lookup)
          end
        end

        def reverse_lookup_alias
          self.target_klass.custom_field_name_to_alias(self.reverse_lookup)
        end

        def apply_has_many_type(klass)
          klass.class_eval <<-EOF

            before_validation :store_#{self.safe_alias.singularize}_ids

            after_save :persist_#{self.safe_alias}

            def #{self.safe_alias}=(ids_or_objects)
              self.#{self.safe_alias}.update(ids_or_objects)
            end

            def #{self.safe_alias}
              @_#{self._name} ||= build_#{self.safe_alias.singularize}_proxy_collection
            end

            def #{self.safe_alias}_klass
              '#{self.target.to_s}'.constantize rescue nil
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
              def build_#{self.safe_alias.singularize}_proxy_collection
                ::CustomFields::Types::HasMany::ReverseLookupProxyCollection.new(self, self.#{self.safe_alias}_klass, '#{self._name}', {
                  :reverse_lookup_field => '#{self.safe_reverse_lookup}'
                })
              end
            EOF
          else
            klass.class_eval <<-EOF
              def build_#{self.safe_alias.singularize}_proxy_collection
                ::CustomFields::Types::HasMany::ProxyCollection.new(self, self.#{self.safe_alias}_klass, '#{self._name}').tap do |collection|
                  collection.reload.update(self.#{self._name})
                end
              end
            EOF
          end
        end

        def add_has_many_validation(klass)
          puts "called add_has_many_validation #{klass.inspect} / #{self.required?.inspect}"
          if self.required?
            klass.validates_length_of self.safe_alias.to_sym, :minimum => 1, :too_short => :blank
          end
        end

      end

    end
  end
end
