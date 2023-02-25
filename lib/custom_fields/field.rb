# frozen_string_literal: true

module CustomFields
  class Field
    include ::Mongoid::Document
    include ::Mongoid::Timestamps

    AVAILABLE_TYPES = %w[default string text email date date_time boolean file select float integer
                         money tags color relationship_default belongs_to has_many many_to_many password json].freeze

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
    field :required,  type: 'Boolean', default: false
    field :unique,    type: 'Boolean', default: false
    field :localized, type: 'Boolean', default: false
    field :default

    ## validations ##
    validates_presence_of   :label, :type
    validates_exclusion_of  :name, in: ->(_f) { CustomFields.options[:reserved_names].map(&:to_s) }
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
      method_name = :"collect_#{type}_diff"

      if respond_to?(method_name)
        send(method_name, memo)
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
      method_name       = :"#{type}_to_recipe"
      custom_to_recipe  = begin
        send(method_name)
      rescue StandardError
        {}
      end

      { 'name' => name,
        'type' => type,
        'required' => required?,
        'unique' => unique?,
        'localized' => localized?,
        'default' => default }.merge(custom_to_recipe)
    end

    def as_json(options = {})
      method_name     = :"#{type}_as_json"
      custom_as_json  = begin
        send(method_name)
      rescue StandardError
        {}
      end

      super(options).merge(custom_as_json)
    end

    protected

    def uniqueness_of_label_and_name
      errors.add(:label, :taken) if siblings.any? { |f| f.label == label && f._id != _id }

      return unless siblings.any? { |f| f.name == name && f._id != _id }

      errors.add(:name, :taken)
    end

    def set_name
      return if label.blank? && name.blank?

      return unless name.blank?

      self.name = ActiveSupport::Inflector.parameterize(label, separator: '_').gsub('-', '_').downcase
    end

    def siblings
      _parent.send(association_name)
    end
  end
end
