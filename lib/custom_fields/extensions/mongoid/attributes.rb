  module Mongoid
  module Attributes

    # FIXME: ::Mongoid::Fields::I18n.locale is also a valid locale
    def selection_included?(name, selection, field)
      if field && field.localized?
        selection.has_key?("#{name}.#{::I18n.locale}") || selection.has_key?("#{name}.#{::Mongoid::Fields::I18n.locale}")
      else
        selection.has_key?(name)
      end
    end

  end
end
