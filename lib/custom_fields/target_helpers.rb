module CustomFields

  module TargetHelpers

    # Returns the list of the getters dynamically based on the
    # custom_fields recipe in order to get the formatted values
    # of the custom fields.
    # If a block is passed, then the list will be filtered accordingly with
    # the following logic. If the block is evaluated as true, then the method
    # will be kept in the list, otherwise it will be removed.
    #
    # @example
    #   # keep all the methods except for the field named 'foo'
    #   project.custom_fields_methods do |rule|
    #     rule['name] != 'foo'
    #   end
    #
    # @returns [ List ] a list of method names (string)
    #
    def custom_fields_methods(&filter)
      self.custom_fields_recipe['rules'].map do |rule|
        method = self.custom_fields_getters_for rule['name'], rule['type']
        if block_given?
          filter.call(rule) ? method : nil
        else
          method
        end
      end.compact.flatten
    end

    # Lists all the attributes that are used by the custom_fields
    # in order to get updated thru a html form for instance.
    #
    # @returns [ List ] a list of attributes (string)
    #
    def custom_fields_safe_attributes
      self.custom_fields_recipe['rules'].map do |rule|
        case rule['type'].to_sym
        when :date                    then "formatted_#{rule['name']}"
        when :file                    then [rule['name'], "remove_#{rule['name']}"]
        when :select, :belongs_to     then ["#{rule['name']}_id", "position_in_#{rule['name']}"]
        when :has_many, :many_to_many then nil
        else
          rule['name']
        end
      end.compact.flatten
    end

    # Determines if the rule defined by the name is a "many" relationship kind.
    # A "many" relationship includes "has_many" and "many_to_many"
    #
    # @params [ String ] name The name of the rule
    #
    # @returns [ Boolean ] True if the rule is a "many" relationship kind.
    #
    def is_a_custom_field_many_relationship?(name)
      rule = self.custom_fields_recipe['rules'].detect do |rule|
        rule['name'] == name && _custom_field_many_relationship?(rule['type'])
      end
    end

    # Returns the names of all the file custom_fields of this object
    #
    # @returns [ Array ] List of names
    #
    def file_custom_fields
      group_custom_fields 'file'
    end

    # Returns the names of all the has_many custom_fields of this object
    #
    # @returns [ Array ] Array of array [name, inverse_of]
    #
    def has_many_custom_fields
      group_custom_fields('has_many') { |rule| [rule['name'], rule['inverse_of']] }
    end

    # Returns the names of all the many_to_many custom_fields of this object.
    # It also adds the property used to set/get the target ids.
    #
    # @returns [ Array ] Array of array [name, <name in singular>_ids]
    #
    def many_to_many_custom_fields
      group_custom_fields('many_to_many') { |rule| [rule['name'], "#{rule['name'].singularize}_ids"] }
    end

    protected

    # Gets the names of the getter methods for a field.
    # The names depend on the field type.
    #
    # @params [ String ] name Name of the field
    # @params [ String ] type Type of the field
    #
    # @returns [ Object ] A string or an array of names
    #
    def custom_fields_getters_for(name, type)
      case type.to_sym
      when :select      then [name, "#{name}_id"]
      when :date        then "formatted_#{name}"
      when :file        then "#{name}_url"
      when :belongs_to  then "#{name}_id"
      else
        name
      end
    end

    #:nodoc:
    def _custom_field_many_relationship?(type)
      %w(has_many many_to_many).include?(type)
    end

    #:nodoc:
    def group_custom_fields(type, &block)
      unless block_given?
        block = lambda { |rule| rule['name'] }
      end

      self.custom_fields_recipe['rules'].find_all { |rule| rule['type'] == type }.map(&block)
    end

  end

end