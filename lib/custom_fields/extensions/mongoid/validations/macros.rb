module Mongoid
  module Validations
    module Macros
      extend ActiveSupport::Concern

      # Validates the size of a collection.
      #
      # @example
      #   class Person
      #     include Mongoid::Document
      #     has_many :addresses
      #
      #     validates_collection_size_of :addresses, minimum: 1
      #   end
      #
      # @param [ Array ] args The names of the fields to validate.
      #
      # @since 2.4.0
      def validates_collection_size_of(*args)
        validates_with(Mongoid::Validations::CollectionSizeValidator, _merge_attributes(args))
      end

    end
  end
end