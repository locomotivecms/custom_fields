#!/usr/bin/env ruby

SimpleCov.start do
  add_filter '/spec/'
end if ENV['COVERAGE']