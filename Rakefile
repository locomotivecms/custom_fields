#!/usr/bin/env rake

require 'rubygems'
require 'bundler/setup'

require 'rspec/core/rake_task'
require 'rubygems/package_task'

lib = File.expand_path '../lib', __FILE__
$:.unshift lib unless $:.include? lib

require 'custom_fields/version'

# === RubyGems ===

gemspec = eval(File.read('custom_fields.gemspec'))

Gem::PackageTask.new(gemspec) do |pkg|
  pkg.gem_spec = gemspec
end

desc 'Build the gem and publish it to RubyGems.'
task release: :gem do
  sh "gem push pkg/custom_fields-#{gemspec.version}.gem"
end

# === RSpec ===

RSpec::Core::RakeTask.new('spec:unit') do |spec|
  spec.pattern = 'spec/unit/**/*_spec.rb'
end

RSpec::Core::RakeTask.new('spec:integration') do |spec|
  spec.pattern = 'spec/integration/**/*_spec.rb'
end

task spec: ['spec:unit', 'spec:integration']


# Set default Rake tasks.
task default: :spec
