# encoding: utf-8
module Mongoid
  module Relations

    module Options

      def validate_with_custom_fields!(options)
        _options = options.dup
        _options.delete(:custom_fields_parent_klass)
        validate_without_custom_fields!(_options)
      end

      alias_method :validate_without_custom_fields!, :validate!
      alias_method :validate!, :validate_with_custom_fields!

    end

  end
end
