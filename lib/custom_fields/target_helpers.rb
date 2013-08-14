module CustomFields

  module TargetHelpers

    # Return the list of the getters dynamically based on the
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
    # @return [ List ] a list of method names (string)
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

    # List all the setters that are used by the custom_fields
    # in order to get updated thru a html form for instance.
    #
    # @return [ List ] a list of method names (string)
    #
    def custom_fields_safe_setters
      self.custom_fields_recipe['rules'].map do |rule|
        case rule['type'].to_sym
        when :date, :date_time, :money  then "formatted_#{rule['name']}"
        when :file                      then [rule['name'], "remove_#{rule['name']}"]
        when :select, :belongs_to       then ["#{rule['name']}_id", "position_in_#{rule['name']}"]
        when :has_many, :many_to_many   then nil
        else
          rule['name']
        end
      end.compact.flatten
    end

    # Build a hash for all the non-relationship fields
    # meaning string, text, date, boolean, select, file types.
    # This hash stores their name and their value.
    #
    # @return [ Hash ] Field name / formatted value
    #
    def custom_fields_basic_attributes
      {}.tap do |hash|
        self.non_relationship_custom_fields.each do |rule|
          name, type = rule['name'], rule['type'].to_sym

          # method of the custom getter
          method_name = "#{type}_attribute_get"

          hash.merge!(self.class.send(method_name, self, name))
        end
      end
    end

    # Set the values (and their related fields) for all the non-relationship fields
    # meaning string, text, date, boolean, select, file types.
    #
    # @param [ Hash ] The attributes for the custom fields and their related fields.
    #
    def custom_fields_basic_attributes=(attributes)
      self.non_relationship_custom_fields.each do |rule|
        name, type = rule['name'], rule['type'].to_sym

        # method of the custom getter
        method_name = "#{type}_attribute_set"

        self.class.send(method_name, self, name, attributes)
      end
    end

    # Check if the rule defined by the name is a "many" relationship kind.
    # A "many" relationship includes "has_many" and "many_to_many"
    #
    # @param [ String ] name The name of the rule
    #
    # @return [ Boolean ] True if the rule is a "many" relationship kind.
    #
    def is_a_custom_field_many_relationship?(name)
      rule = self.custom_fields_recipe['rules'].detect do |rule|
        rule['name'] == name && _custom_field_many_relationship?(rule['type'])
      end
    end

    # Return the rules of the custom fields which do not describe a relationship.
    #
    # @return [ Array ] List of rules (Hash)
    #
    def non_relationship_custom_fields
      self.custom_fields_recipe['rules'].find_all do |rule|
        !%w(belongs_to has_many many_to_many).include?(rule['type'])
      end
    end

    # Return the rules of the custom fields which describe a relationship.
    #
    # @return [ Array ] List of rules (Hash)
    #
    def relationship_custom_fields
      self.custom_fields_recipe['rules'].find_all do |rule|
        %w(belongs_to has_many many_to_many).include?(rule['type'])
      end
    end

    # Return the names of all the select fields of this object
    def select_custom_fields
      group_custom_fields 'select'
    end

    # Return the names of all the file custom_fields of this object
    #
    # @return [ Array ] List of names
    #
    def file_custom_fields
      group_custom_fields 'file'
    end

    # Return the names of all the belongs_to custom_fields of this object
    #
    # @return [ Array ] List of names
    #
    def belongs_to_custom_fields
      group_custom_fields 'belongs_to'
    end

    # Return the names of all the has_many custom_fields of this object
    #
    # @return [ Array ] Array of array [name, inverse_of]
    #
    def has_many_custom_fields
      group_custom_fields('has_many') { |rule| [rule['name'], rule['inverse_of']] }
    end

    # Return the names of all the many_to_many custom_fields of this object.
    # It also adds the property used to set/get the target ids.
    #
    # @return [ Array ] Array of array [name, <name in singular>_ids]
    #
    def many_to_many_custom_fields
      group_custom_fields('many_to_many') { |rule| [rule['name'], "#{rule['name'].singularize}_ids"] }
    end

    protected

    # Get the names of the getter methods for a field.
    # The names depend on the field type.
    #
    # @param [ String ] name Name of the field
    # @param [ String ] type Type of the field
    #
    # @return [ Object ] A string or an array of names
    #
    def custom_fields_getters_for(name, type)
      case type.to_sym
      when :select                    then [name, "#{name}_id"]
      when :date, :date_time, :money  then "formatted_#{name}"
      when :file                      then "#{name}_url"
      when :belongs_to                then "#{name}_id"
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
