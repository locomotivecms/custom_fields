#!/usr/bin/env ruby
# frozen_string_literal: true

if ENV['COVERAGE']
  SimpleCov.start do
    add_filter '/spec/'
  end
end
