#!/usr/bin/env rake
# encoding: utf-8

require 'rubygems'
require 'bundler/setup'

require 'rake'
require 'rspec'
require 'rspec/core/rake_task'
require 'rubygems/package_task'
require 'yard'

# require 'bundler'
# Bundler.setup
#
# require 'rake'
# require 'yard'
# require 'rspec'
# require 'rspec/core/rake_task'
# require 'rubygems/package_task'


$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)
require 'custom_fields/version'

gemspec = eval(File.read('custom_fields.gemspec'))
Gem::PackageTask.new(gemspec) do |pkg|
  pkg.gem_spec = gemspec
end

desc 'build the gem and release it to rubygems.org'
task :release => :gem do
  sh "gem push pkg/custom_fields-#{gemspec.version}.gem"
end

desc 'Generate documentation for the custom_fields plugin.'
YARD::Rake::YardocTask.new do |t|
  t.files   = ['lib/**/*.rb']   # optional
  t.options = ['--title', "CustomFields #{CustomFields::VERSION}", '--file', 'README.textile']
end

RSpec::Core::RakeTask.new('spec:unit') do |spec|
  spec.pattern = 'spec/unit/**/*_spec.rb'
end

RSpec::Core::RakeTask.new('spec:integration') do |spec|
  spec.pattern = 'spec/integration/**/*_spec.rb'
end

task :spec => ['spec:unit', 'spec:integration']

task :default => :spec