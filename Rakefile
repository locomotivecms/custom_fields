#!/usr/bin/env rake

require 'rubygems'
require 'bundler/setup'
require 'bundler/gem_tasks'

require 'rake'
require 'rspec'

# === Gems install tasks ===
Bundler::GemHelper.install_tasks

require_relative 'lib/custom_fields'

# === RSpec ===

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new('spec')

RSpec::Core::RakeTask.new('spec:unit') do |spec|
  spec.pattern = 'spec/unit/**/*_spec.rb'
end

RSpec::Core::RakeTask.new('spec:integration') do |spec|
  spec.pattern = 'spec/integration/**/*_spec.rb'
end

# Set default Rake tasks.
task default: [:spec]
