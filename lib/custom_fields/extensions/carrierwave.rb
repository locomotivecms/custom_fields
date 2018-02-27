require 'carrierwave/mongoid'

module CarrierWave

  module Mongoid

    def mount_uploader_with_localization(column, uploader=nil, options={}, &block)
      mount_uploader_without_localization(column, uploader, options, &block)

      define_method(:read_uploader) do |name|
        # puts "read_uploader #{name} / #{read_attribute(name.to_sym).inspect}" # DEBUG

        value = read_attribute(name.to_sym)
        unless value.nil?
          self.class.fields[name.to_s].demongoize(value)
        else
          nil
        end
      end
    end

    alias_method :mount_uploader_without_localization, :mount_uploader
    alias_method :mount_uploader, :mount_uploader_with_localization

  end

  class Mounter

    def remove_previous_with_localization(before=nil, after=nil)
      _after = after

      if after && after.first.is_a?(Hash)
        locale = ::Mongoid::Fields::I18n.locale.to_s
        _after = [after.first[locale]]
      end

      remove_previous_without_localization(before, _after)
    end

    alias_method :remove_previous_without_localization, :remove_previous
    alias_method :remove_previous, :remove_previous_with_localization


  end

end


