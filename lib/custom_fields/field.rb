module CustomFields

  class Field

    include ::Mongoid::Document
    include ::Mongoid::Timestamps

    ## types ##
    include Types::Default
    include Types::String
    include Types::Text
    include Types::Date
    include Types::Boolean
    include Types::File

    # include Types::File
    # include Types::Category
    # include Types::HasOne
    # include Types::HasMany

    ## fields ##
    field :label
    field :name
    field :type
    field :hint
    field :position, :type => Integer, :default => 0
    field :required, :type => Boolean, :default => false

    ## validations ##
    validates_presence_of   :label, :type
    validates_exclusion_of  :name, :in => lambda { |f| CustomFields.options[:reserved_names].map(&:to_s) }
    validates_format_of     :name, :with => /^[a-z]([A-Za-z0-9_]+)?$/
    validate                :uniqueness_of_label_and_name

    ## other accessors ##

    ## callbacks ##
    before_validation :set_name

    ## methods ##

    #
    # TODO
    #
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

    #
    # TODO
    #
    def to_recipe
      method_name       = :"#{self.type}_to_recipe"
      custom_to_recipe  = self.send(method_name) rescue {}

      { 'name' => self.name, 'type' => self.type, 'required' => self.required }.merge(custom_to_recipe)
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

    def uniqueness_of_label_and_name
      if self.siblings.any? { |f| f.label == self.label && f._id != self._id }
        self.errors.add(:label, :taken)
      end

      if self.siblings.any? { |f| f.name == self.name && f._id != self._id }
        self.errors.add(:name, :taken)
      end
    end

    def set_name
      return if self.label.blank? && self.name.blank?

      if self.name.blank?
        self.name = self.label.parameterize('_').gsub('-', '_').downcase
      end
    end

    def siblings
      self._parent.send(self.metadata.name)
    end

  end

end