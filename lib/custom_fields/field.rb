module CustomFields

  class Field

    include ::Mongoid::Document
    include ::Mongoid::Timestamps

    ## types ##
    %w(default string text date boolean file select relationship_default belongs_to has_many many_to_many).each do |type|
      include "CustomFields::Types::#{type.classify}::Field".constantize
    end

    ## fields ##
    field :label
    field :name
    field :type
    field :hint
    field :position,  :type => Integer, :default => 0
    field :required,  :type => Boolean, :default => false
    field :localized, :type => Boolean, :default => false

    ## validations ##
    validates_presence_of   :label, :type
    validates_exclusion_of  :name, :in => lambda { |f| CustomFields.options[:reserved_names].map(&:to_s) }
    validates_format_of     :name, :with => /^[a-z]([A-Za-z0-9_]+)?$/
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

      { 'name' => self.name, 'type' => self.type, 'required' => self.required?, 'localized' => self.localized? }.merge(custom_to_recipe)
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
        self.name = self.label.parameterize('_').gsub('-', '_').downcase
      end
    end

    def siblings
      self._parent.send(self.metadata.name)
    end

  end

end