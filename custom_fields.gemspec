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
    'LICENSE',
    'README.md',
    '{lib}/**/*',
    '{config}/**/*'
  ]

  spec.extra_rdoc_files = [
    'LICENSE',
    'README.md'
  ]

  spec.required_ruby_version = '~> 2.1'

  spec.required_rubygems_version = '~> 2.4'

  spec.add_dependency 'mongoid',             '~> 5.2.0'
  spec.add_dependency 'carrierwave-mongoid', '~> 0.10.0'
  spec.add_dependency 'activesupport',       '~> 4.2.7'
  spec.add_dependency 'monetize',            '~> 1.6.0'
  spec.add_dependency 'bcrypt',              '~> 3.1.11'
end
