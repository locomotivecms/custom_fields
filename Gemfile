#!/usr/bin/env bundle

source 'https://rubygems.org'

gemspec # Include gemspec dependencies

gem 'rake',         '~> 13.0.6'
gem 'pry-byebug',   '~> 3.10.1'

gem 'database_cleaner-mongoid', '~> 2.0.1'

gem 'carrierwave-google-storage', require: false

group :test do
  gem 'rspec',            '~> 3.12.0'
  gem 'rspec-its',        '~> 1.3.0'
  gem 'mocha',            '~> 2.0.2'
  
  gem 'coveralls',                  '~> 0.8.23', require: false
end

platform :ruby do
  ruby File.read('.ruby-version').strip
end
