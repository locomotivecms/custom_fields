require "rubygems"
require "rake"
require "rake/rdoctask"
require "rspec"
require "rspec/core/rake_task"
require 'rake/gempackagetask'


gemspec = eval(File.read('custom_fields.gemspec'))
Rake::GemPackageTask.new(gemspec) do |pkg|
  pkg.gem_spec = gemspec
end

desc "build the gem and release it to rubygems.org"
task :release => :gem do
  sh "gem push pkg/custom_fields-#{gemspec.version}.gem"
end

desc 'Generate documentation for the custom_fields plugin.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'CustomFields'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

Rspec::Core::RakeTask.new('spec:unit') do |spec|
  spec.pattern = "spec/unit/**/*_spec.rb"
  # spec.pattern = "spec/unit/proxy_class_caching_spec.rb"
  # spec.pattern = "spec/unit/proxy_class_enabler_spec.rb"
  # spec.pattern = "spec/unit/custom_field_spec.rb"
  # spec.pattern = "spec/unit/custom_fields_for_spec.rb"
  # spec.pattern = "spec/unit/types/category_spec.rb"
  # spec.pattern = "spec/unit/types/date_spec.rb"
  # spec.pattern = "spec/unit/types/default_spec.rb"
  # spec.pattern = "spec/unit/types/*_spec.rb"
end

Rspec::Core::RakeTask.new('spec:integration') do |spec|
  spec.pattern = "spec/integration/**/*_spec.rb"
  # spec.pattern = "spec/integration/custom_fields_for_spec.rb"
  # spec.pattern = "spec/integration/types/category_spec.rb"
  # spec.pattern = "spec/integration/types/has_one_spec.rb"
  # spec.pattern = "spec/integration/types/has_many_spec.rb"
  # spec.pattern = "spec/integration/types/has_*_spec.rb"
end

task :spec => ['spec:unit', 'spec:integration']

task :default => :spec
