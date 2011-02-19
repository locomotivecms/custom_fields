module CustomFields

  class Field
    include ::Mongoid::Document
    include ::Mongoid::Timestamps

    # types ##
    include Types::Default
    include Types::String
    include Types::Text
    include Types::Category
    include Types::Boolean
    include Types::Date
    include Types::File

    ## fields ##
    field :label
    field :_alias
    field :_name
    field :kind
    field :hint
    field :position, :type => Integer, :default => 0
    field :required, :type => Boolean, :default => false

    ## validations ##
    validates_presence_of :label, :kind
    validates_exclusion_of :_alias, :in => Mongoid.destructive_fields
    validate :uniqueness_of_label_and_alias

    ## other accessors ##
    attr_accessor :association_name # missing in 2.0.0 rc

    ## methods ##

    def field_type
      self.class.field_types[self.kind.downcase.to_sym]
    end

    def apply(klass)
      return false unless self.valid?

      klass.field self._name, :type => self.field_type if self.field_type

      apply_method_name = :"apply_#{self.kind.downcase}_type"

      if self.respond_to?(apply_method_name)
        self.send(apply_method_name, klass)
      else
        apply_default_type(klass)
      end

      true
    end

    def safe_alias
      self.set_alias
      self._alias
    end

    def write_attributes_with_invalidation(attrs = nil)
      if self.association_name.to_s == '_metadata_custom_fields'
        target_name = 'metadata'
      else
        target_name = self.association_name.to_s.gsub('_custom_fields', '').pluralize
      end

      klass = self._parent.send(target_name).metadata.klass

      write_attributes_without_invalidation(attrs)

      klass.apply_custom_field(self)
    end

    alias_method_chain :write_attributes, :invalidation

    protected

    def uniqueness_of_label_and_alias
      if self.siblings.any? { |f| f.label == self.label && f._id != self._id }
        self.errors.add(:label, :taken)
      end

      if self.siblings.any? { |f| f._alias == self._alias && f._id != self._id }
        self.errors.add(:_alias, :taken)
      end
    end

    def set_unique_name!
      self._name ||= "custom_field_#{self.increment_counter!}"
    end

    def set_alias
      return if self.label.blank? && self._alias.blank?
      self._alias = (self._alias.blank? ? self.label : self._alias).parameterize('_').downcase
    end

    def increment_counter!
      next_value = (self._parent.send(:"#{self.association_name}_counter") || 0) + 1
      self._parent.send(:"#{self.association_name}_counter=", next_value)
      next_value
    end

    def siblings
      self._parent.send(self.association_name)
    end

    def parentize_with_custom_fields(object)
      object_name = object.class.to_s.underscore

      self.association_name = self.metadata ? self.metadata.name : self.relations[object_name].inverse_of

      if !self.relations.key?(object_name)
        self.singleton_class.embedded_in object_name.to_sym, :inverse_of => self.association_name
      end

      parentize_without_custom_fields(object)

      self.send(:set_unique_name!)
      self.send(:set_alias)
    end

    alias_method_chain :parentize, :custom_fields

  end

end
