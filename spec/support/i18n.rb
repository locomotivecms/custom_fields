# frozen_string_literal: true

require 'i18n/backend/fallbacks'

I18n::Backend::Simple.include I18n::Backend::Fallbacks

::I18n.fallbacks[:fr] = %i[fr en]
::I18n.fallbacks[:de] = %i[de en]
