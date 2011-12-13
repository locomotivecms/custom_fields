module CustomFields

  class Field

    include ::Mongoid::Document
    include ::Mongoid::Timestamps

    ## types ##
    include Types::Default
    # include Types::String
    # include Types::Text
    # include Types::Category
    # include Types::Boolean
    # include Types::Date
    # include Types::File
    # include Types::HasOne
    # include Types::HasMany

    ## fields ##
    field :label
    field :alias
    field :type
    field :hint
    field :position, :type => Integer, :default => 0
    field :required, :type => Boolean, :default => false

    ## validations ##
    validates_presence_of   :label, :type
    validates_exclusion_of  :alias, :in => lambda { |f| CustomFields.options[:reserved_aliases].map(&:to_s) }
    validates_format_of     :alias, :with => /^[a-z]([A-Za-z0-9_]+)?$/
    validate                :uniqueness_of_label_and_alias

    ## other accessors ##
    # attr_accessor :_diff_memo

    ## callbacks ##
    before_validation :set_alias

    ## methods ##

    def collect_diff(memo)
      method_name = :"collect_#{self.type}_diff"

      if self.respond_to?(method_name)
        self.send(method_name, memo)
      else
        collect_default_diff(memo)
      end
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
      CustomFields::Field.without_callback(:save, :before, :invalidate_proxy_klass) do
        self.valid?
      end
    end

    def to_recipe
      { :alias => self.alias, :type => self.type, :required => self.required }
    end

    # # Collects all the important attributes of this field.
    # # It also accepts an extra hash which will be merged with
    # # the one built by this method (by default, this is an empty hash)
    # #
    # # @param [ Hash ] more The extra hash
    # #
    # # @return [ Hash ] the hash
    # #
    # def to_hash(more = {})
    #   self.fields.keys.inject({}) do |memo, meth|
    #     memo[meth] = self.send(meth.to_sym); memo
    #   end.tap do |hash|
    #     self.class.field_types.keys.each do |type|
    #       if self.respond_to?(:"#{type}_to_hash")
    #         hash.merge!(self.send(:"#{type}_to_hash"))
    #       end
    #     end
    #   end.merge({
    #     'id'          => self._id,
    #     'new_record'  => self.new_record?,
    #     'errors'      => self.errors,
    #     'kind_name'   => I18n.t("custom_fields.kind.#{self.safe_kind}")
    #   }).merge(more)
    # end
    #
    # # Overides the default behaviour of the to_json method by using the to_hash method
    # #
    # # @return [ String ] the json object
    # #
    # def to_json
    #   ActiveSupport::JSON.encode(self.to_hash)
    # end

    protected

    def uniqueness_of_label_and_alias
      if self.siblings.any? { |f| f.label == self.label && f._id != self._id }
        self.errors.add(:label, :taken)
      end

      if self.siblings.any? { |f| f.alias == self.alias && f._id != self._id }
        self.errors.add(:alias, :taken)
      end
    end

    def set_alias
      return if self.label.blank? && self.alias.blank?

      if self.alias.blank?
        self.alias = self.label.parameterize('_').gsub('-', '_').downcase
      end
    end

    def siblings
      self._parent.send(self.metadata.name)
    end

  end

end