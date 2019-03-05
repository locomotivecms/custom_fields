#!/usr/bin/env bundle

source 'https://rubygems.org'

gemspec # Include gemspec dependencies

gem 'rake',         '~> 12.3.0'
gem 'pry-byebug',   '~> 3.6.0'

gem 'database_cleaner'

gem 'carrierwave-google-storage', require: false

group :test do
  gem 'rspec',            '~> 3.7.0'
  gem 'rspec-its',        '~> 1.2.0'
  gem 'mocha',            '~> 1.3.0'

  gem 'codeclimate-test-reporter',  '~> 1.0.7',  require: false
  gem 'coveralls',                  '~> 0.8.19', require: false
end

platform :ruby do
  ruby '2.6.1'
end
