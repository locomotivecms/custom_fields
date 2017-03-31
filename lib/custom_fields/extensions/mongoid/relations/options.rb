module CustomFieldsOptionsExtension
  module ClassMethods
    def validate!(options)
      valid_options = options[:relation].valid_options + ::Mongoid::Relations::Options::COMMON
      options.keys.each do |key|
        if !valid_options.include?(key)
          raise Errors::InvalidOptions.new(
            options[:name],
            key,
            valid_options
          )
        end
      end
      true
    end
  end

  def self.prepended(base)
    class << base
      prepend ClassMethods
    end
  end
end

::Mongoid::Relations::Options.send(:prepend, CustomFieldsOptionsExtension)
