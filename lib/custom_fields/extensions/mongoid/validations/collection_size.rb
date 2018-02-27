module Mongoid
  module Validations

    # Validates that the specified collections do or do not match a certain
    # size.
    #
    # @example Set up the collection size validator.
    #
    #   class Person
    #     include Mongoid::Document
    #     has_many :addresses
    #
    #     validates_collection_size_of :addresses, in: 1..10
    #   end
    class CollectionSizeValidator < Mongoid::Validatable::LengthValidator

      def validate_each_with_collection(record, attribute, value)
        value = collection_to_size(record, attribute)

        self.validate_each_without_collection(record, attribute, value)
      end

      alias_method :validate_each_without_collection, :validate_each
      alias_method :validate_each, :validate_each_with_collection

      private

      def collection_to_size(record, attribute)
        relation = record.relations[attribute.to_s]

        source = case relation.macro
        when :embeds_many, :has_many
          record.send(attribute)
        when :has_and_belongs_to_many
          record.send(relation.key.to_sym)
        end

        OpenStruct.new(length: source.try(:size) || 0)
      end

    end
  end
end
