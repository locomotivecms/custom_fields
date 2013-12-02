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
  s.summary     = 'Custom fields extension for Mongoid'
  s.description = 'Manage custom fields to a mongoid document or a collection. This module is one of the core features we implemented in our custom cms named Locomotive.'

  s.required_rubygems_version = '>= 1.3.6'
  s.rubyforge_project         = 'nowarning'

  s.add_dependency 'mongoid', '~> 4.0.0.alpha1'
  s.add_dependency 'activesupport', '~> 4.0'
  s.add_dependency 'carrierwave-mongoid', '~> 0.6.0'
  s.add_dependency 'money', '~> 5.0'

  s.add_development_dependency('yard', ['~> 0.7.3'])
  s.add_development_dependency('mocha', ['~> 0.9.12'])
  s.add_development_dependency('rspec', ['~> 2.6'])
  s.add_development_dependency('simplecov', ['~> 0.6.1'])
  s.add_development_dependency('database_cleaner', ['~> 0.9.1'])
  s.add_development_dependency('pry')
  s.add_development_dependency('RedCloth', ['~> 4.2.8'])

  s.files        = Dir[ 'init.rb',
                        'MIT-LICENSE',
                        'README.textile',
                        '{lib}/**/*',
                        '{config}/**/*']

  s.require_path = 'lib'

  s.extra_rdoc_files = [
    'MIT-LICENSE',
    'README.textile'
  ]

end
