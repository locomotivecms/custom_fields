module Mongoid #:nodoc

  # This module defines behaviour for fields.
  module Fields

    module ClassMethods

      # Replace a field with a new type.
      #
      # @example Replace the field.
      #   Model.replace_field("_id", String)
      #
      # @param [ String ] name The name of the field.
      # @param [ Class ] type The new type of field.
      # @param [ Boolean ] localize The option to localize or not the field.
      #
      # @return [ Serializable ] The new field.
      #
      # @since 2.1.0
      def replace_field(name, type, localize = false)
        # puts "fields[#{name}] = #{fields[name.to_s].inspect} / #{fields.keys.inspect}" # DEBUG
        defaults.delete_one(name)
        add_field(name, fields[name.to_s].options.merge(:type => type, :localize => localize))
      end

    end

  end

end