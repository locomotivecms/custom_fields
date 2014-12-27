#!/usr/bin/env gem build

lib = File.expand_path '../lib', __FILE__
$:.unshift lib unless $:.include? lib

require 'custom_fields/version'

Gem::Specification.new 'custom_fields', CustomFields::VERSION do |spec|
  spec.summary     = 'Custom fields extension for Mongoid.'
  spec.description = 'Manage custom fields to a Mongoid document or a collection. This module is one of the core features we implemented in our custom CMS, named LocomotiveCMS.'
  spec.author      = 'Didier Lafforgue'
  spec.email       = 'didier@nocoffee.fr'
  spec.homepage    = 'https://github.com/locomotivecms/custom_fields'
  spec.license     = 'MIT'

  spec.files = Dir[
    'MIT-LICENSE',
    'README.textile',
    '{lib}/**/*',
    '{config}/**/*'
  ]

  spec.extra_rdoc_files = [
    'LICENSE',
    'README.textile'
  ]

  spec.required_ruby_version = '~> 2.1'

  spec.required_rubygems_version = '~> 2.4'

  spec.add_dependency 'mongoid',             '~> 4.0.0'
  spec.add_dependency 'carrierwave-mongoid', '~> 0.7.1'
  spec.add_dependency 'activesupport',       '~> 4.1.8'
  spec.add_dependency 'money',               '~> 5.1.1'

  spec.add_development_dependency 'rspec',            '~> 2.99'
  spec.add_development_dependency 'rspec-its',        '~> 1.0.1'
  spec.add_development_dependency 'mocha',            '~> 0.9.12'
  spec.add_development_dependency 'simplecov',        '~> 0.6.1'
  spec.add_development_dependency 'database_cleaner', '~> 0.9.1'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'RedCloth',         '~> 4.2.9'
  spec.add_development_dependency 'yard',             '~> 0.7.5'
end