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
    include Types::HasOne
    include Types::HasMany

    ## fields ##
    field :label
    field :_alias
    field :_name
    field :kind
    field :hint
    field :position, :type => Integer, :default => 0
    field :required, :type => Boolean, :default => false

    ## validations ##
    validates_presence_of   :label, :kind
    validates_exclusion_of  :_alias, :in => lambda { |f| CustomFields.options[:reserved_aliases].map(&:to_s) }
    validates_format_of     :_alias, :with => /^[a-z]([A-Za-z0-9_]+)?$/
    validate                :uniqueness_of_label_and_alias

    ## other accessors ##
    attr_accessor :parentized_done # for performance purpose

    ## callbacks ##
    before_validation :set_alias
    after_validation  :invalidate_proxy_klass
    # before_save       :invalidate_proxy_klass
    after_destroy     :invalidate_proxy_klass

    ## methods ##

    # Returns the type class related to this field
    #
    # @return [ Class ] The class defining the field type
    #
    def field_type
      self.class.field_types[self.safe_kind.to_sym]
    end

    # Enhance a document class by applying to it the information stored
    # in the type related to this field
    #
    # @param [ Class ] klass The document class
    #
    def apply(klass)
      klass.field self._name, :type => self.field_type if self.field_type

      apply_method_name = :"apply_#{self.safe_kind}_type"

      if self.respond_to?(apply_method_name)
        self.send(apply_method_name, klass)
      else
        apply_default_type(klass)
      end

      validation_method_name = :"add_#{self.safe_kind}_validation"

      if self.respond_to?(validation_method_name)
        self.send(validation_method_name, klass)
      else
        add_default_validation(klass)
      end
    end

    # Make sure it returns a valid alias
    #
    # @return [ String ] the alias
    #
    def safe_alias
      self.set_alias
      self._alias
    end

    # Returns the kind (or type) of the current field.
    # Because of compatibility purpose, prior version of CustomFields used to have the value of kind in uppercase.
    #
    # @return [ String ] the kind
    #
    def safe_kind
      self.kind.downcase
    end

    # Returns the name of the relation binding this field and the custom_fields in the parent class
    #
    # @example:
    #   class Company
    #     embeds_many :employees
    #     custom_fields_for :employees
    #   end
    #
    #   field = company.employees_custom_fields.build :label => 'His/her position', :_alias => 'position', :kind => 'string'
    #   field.custom_fields_relation_name == 'employees'
    #
    # @return [ String ] the relation's name
    #
    def custom_fields_relation_name
      self.metadata.name.to_s.gsub('_custom_fields', '')
    end

    # Checks if the field is valid without running the callback which marks
    # the proxy class as invalidated
    #
    # @return [ Boolean ] true if the field has no errors, false otherwise
    def quick_valid?
      CustomFields::Field.without_callback(:validation, :after, :invalidate_proxy_klass) do
        self.valid?
      end
    end

    # Collects all the important attributes of this field.
    # It also accepts an extra hash which will be merged with
    # the one built by this method (by default, this is an empty hash)
    #
    # @param [ Hash ] more The extra hash
    #
    # @return [ Hash ] the hash
    #
    def to_hash(more = {})
      self.fields.keys.inject({}) do |memo, meth|
        memo[meth] = self.send(meth.to_sym); memo
      end.tap do |hash|
        self.class.field_types.keys.each do |type|
          if self.respond_to?(:"#{type}_to_hash")
            hash.merge!(self.send(:"#{type}_to_hash"))
          end
        end
      end.merge({
        'id'          => self._id,
        'new_record'  => self.new_record?,
        'errors'      => self.errors,
        'kind_name'   => I18n.t("custom_fields.kind.#{self.safe_kind}")
      }).merge(more)
    end

    # Overides the default behaviour of the to_json method by using the to_hash method
    #
    # @return [ String ] the json object
    #
    def to_json
      ActiveSupport::JSON.encode(self.to_hash)
    end

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

      if self._alias.blank?
        self._alias = self.label.parameterize('_').gsub('-', '_').downcase
      end
    end

    def increment_counter!
      name = self.custom_fields_relation_name
      self._parent.bump_custom_fields_counter(name)
    end

    def siblings
      self._parent.send(self.metadata.name)
    end

    def parentize_with_custom_fields(object)
      return if self.parentized_done

      parentize_without_custom_fields(object)

      self.send(:set_unique_name!)

      self.parentized_done = true
    end
    alias_method_chain :parentize, :custom_fields

    def invalidate_proxy_klass
      puts "#{self._name} _ invalidate_proxy_klass !!! #{self.destroyed?}"
      if self.destroyed? || self.changed?
        self.mark_proxy_klass_flag_as_invalidated
      end

      # # if self._parent.instance_variable_get(:@_writing_attributes_with_custom_fields)
      #   if self.destroyed? # force the parent to invalidate the related target class
      #     self.mark_proxy_klass_flag_as_invalidated
      #   elsif self.changed?
      #     self.mark_proxy_klass_flag_as_invalidated
      #   end
      # else
      #   self.mark_proxy_klass_flag_as_invalidated
      #   self._parent.save
      # end
    end

    def mark_proxy_klass_flag_as_invalidated
      # puts "\t*** [mark_proxy_klass_flag_as_invalidated] called for '#{self._name}'"
      name = self.custom_fields_relation_name
      self._parent.mark_klass_with_custom_fields_as_invalidated(name)
    end

  end

end