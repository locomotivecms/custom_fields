#!/usr/bin/env bundle
# frozen_string_literal: true

source 'https://rubygems.org'

gemspec # Include gemspec dependencies

gem 'carrierwave-google-storage', require: false
gem 'database_cleaner-mongoid', '~> 2.0.1'
gem 'pry-byebug', '~> 3.10.1'
gem 'rake', '~> 13.0.6'
gem 'rubocop', require: false

gem 'bigdecimal'
gem 'mutex_m'
gem 'base64'

group :test do
  gem 'coveralls', '~> 0.8.23', require: false
  gem 'mocha', '~> 2.0.2'
  gem 'rspec', '~> 3.12.0'
  gem 'rspec-its', '~> 1.3.0'
end

platform :ruby do
  ruby File.read('.ruby-version').strip
end
