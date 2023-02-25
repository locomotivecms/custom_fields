# frozen_string_literal: true

require 'carrierwave/mongoid'

module CarrierWave
  class Mounter
    def remove_previous_with_localization(before = nil, after = nil)
      _before = before
      _after = after
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
      _before = [before.first[locale]] if before && before.first.is_a?(Hash)

      _after = [after.first[locale]] if after && after.first.is_a?(Hash)

      remove_previous_without_localization(_before, _after)
    end

    alias remove_previous_without_localization remove_previous
    alias remove_previous remove_previous_with_localization
  end
end
