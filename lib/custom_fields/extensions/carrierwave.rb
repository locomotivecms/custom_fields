require 'carrierwave/mongoid'

module CarrierWave

  module Mongoid

    def mount_uploader_with_localization(column, uploader=nil, options={}, &block)
      mount_uploader_without_localization(column, uploader, options, &block)

      define_method(:read_uploader) do |name|
        # puts "read_uploader #{name} / #{read_attribute(name.to_sym).inspect} / #{::Mongoid::Fields::I18n.locale.inspect}" # DEBUG

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

    def remove_previous_with_localization(before = nil, after = nil)
      _before, _after = before, after
      locale = ::Mongoid::Fields::I18n.locale.to_s

      # custom case:
      # the record owns a localized file field. A new file has been attached to it
      # in the default locale. Now, we want to upload a file in another locale with
      # a different name.
      # We absolutely don't want to erase the file in the default locale
      if record.class.fields[column.to_s]&.localized? &&
          record.changes[column]&.first == '_new_'
        _before = [nil]
      end

      # FIXME: can't reproduce this behavior locally but it happens in production
      if before && before.first.is_a?(Hash)
        _before = [before.first[locale]]
      end

      if after && after.first.is_a?(Hash)
        _after = [after.first[locale]]
      end

      remove_previous_without_localization(_before, _after)
    end

    alias_method :remove_previous_without_localization, :remove_previous
    alias_method :remove_previous, :remove_previous_with_localization


  end

end


