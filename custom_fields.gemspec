#!/usr/bin/env gem build
# encoding: utf-8

lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'custom_fields/version'

Gem::Specification.new do |s|
  s.name        = 'custom_fields'
  s.version     = CustomFields::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Didier Lafforgue']
  s.email       = ['didier@nocoffee.fr']
  s.homepage    = 'http://github.com/locomotivecms/custom_fields'
  s.summary     = 'Custom fields extension for Mongoid.'
  s.description = 'Manage custom fields to a Mongoid document or a collection. This module is one of the core features we implemented in our custom CMS named Locomotive.'

  s.required_rubygems_version = '>= 1.3.6'

  # Dependencies
  # ------------

  s.add_dependency 'mongoid',             '~> 2.4.3'
  # s.add_dependency 'carrierwave',         '~> 0.6.0'
  s.add_dependency 'carrierwave-mongoid', '~> 0.1.3'

  s.add_dependency 'activesupport',       '~> 3.2.1'

  s.add_dependency 'SystemTimer',         '~> 1.2.3' if RUBY_VERSION =~ /1.8/

  # Development dependencies
  # ------------------------

  s.add_development_dependency 'rake',             '~> 0.9.2'

  s.add_development_dependency 'mongo',            '~> 1.5.2'
  s.add_development_dependency 'bson',             '~> 1.5.2'
  s.add_development_dependency 'bson_ext',         '~> 1.5.2'
  
  s.add_development_dependency 'rspec',            '~> 2.8'
  s.add_development_dependency 'mocha',            '~> 0.9.12'

  s.add_development_dependency 'database_cleaner', '~> 0.6.7'

  s.add_development_dependency 'yard',             '~> 0.7.5'
  s.add_development_dependency 'RedCloth',         '~> 4.2.9'

  s.files = Dir[ 'init.rb',
                 'MIT-LICENSE',
                 'README.textile',
                 '{lib}/**/*',
                 '{config}/**/*'
               ]

  s.require_path = 'lib'

  s.extra_rdoc_files = [
    'MIT-LICENSE',
    'README.textile'
  ]
end