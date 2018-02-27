module CustomFields

  class Field

    include ::Mongoid::Document
    include ::Mongoid::Timestamps

    AVAILABLE_TYPES = %w(default string text email date date_time boolean file select float integer
       money tags color relationship_default belongs_to has_many many_to_many password json)

    ## types ##
    AVAILABLE_TYPES.each do |type|
      include "CustomFields::Types::#{type.camelize}::Field".constantize
    end

    ## fields ##
    field :label
    field :name
    field :type
    field :hint
    field :position,  type: ::Integer, default: 0
    field :required,  type: ::Boolean, default: false
    field :unique,    type: ::Boolean, default: false
    field :localized, type: ::Boolean, default: false
    field :default

    ## validations ##
    validates_presence_of   :label, :type
    validates_exclusion_of  :name, in: lambda { |f| CustomFields.options[:reserved_names].map(&:to_s) }
    validates_inclusion_of  :type, in: AVAILABLE_TYPES, allow_blank: true
    validates_format_of     :name, with: /^[a-z]([A-Za-z0-9_]+)?$/, multiline: true
    validate                :uniqueness_of_label_and_name

    ## callbacks ##
    before_validation :set_name

    ## methods ##

    # Builds the mongodb updates based on
    # the new state of the field.
    # Call a different method if the field has a different behaviour.
    #
    # @param [ Hash ] memo Store the updates
    #
    # @return [ Hash ] The memo object upgraded
    #
    def collect_diff(memo)
      method_name = :"collect_#{self.type}_diff"

      if self.respond_to?(method_name)
        self.send(method_name, memo)
      else
        collect_default_diff(memo)
      end
    end

    # Returns the information (name, type, required, ...etc) needed to build
    # the custom class.
    # That will be stored into the target instance.
    #
    # @return [ Hash ] The hash
    #
    def to_recipe
      method_name       = :"#{self.type}_to_recipe"
      custom_to_recipe  = self.send(method_name) rescue {}

      { 'name'      => self.name,
        'type'      => self.type,
        'required'  => self.required?,
        'unique'    => self.unique?,
        'localized' => self.localized?,
        'default'   => self.default }.merge(custom_to_recipe)
    end

    def as_json(options = {})
      method_name     = :"#{self.type}_as_json"
      custom_as_json  = self.send(method_name) rescue {}

      super(options).merge(custom_as_json)
    end

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
        self.name = self.label.parameterize(separator: '_').gsub('-', '_').downcase
      end
    end

    def siblings
      # binding.pry
      self._parent.send(self.relation_metadata.name)
    end

  end

end
