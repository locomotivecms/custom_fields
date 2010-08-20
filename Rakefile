require "rubygems"
require "rake"
require "rake/rdoctask"
require "rspec"
require "rspec/core/rake_task"

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
  # spec.pattern = "spec/unit/custom_fields_for_spec.rb"
  # spec.pattern = "spec/unit/types/category_spec.rb"
end

Rspec::Core::RakeTask.new('spec:integration') do |spec|
  spec.pattern = "spec/integration/**/*_spec.rb"
  # spec.pattern = "spec/integration/types/category_spec.rb"
end

task :spec => ['spec:unit', 'spec:integration']

task :default => :spec

begin
  require "jeweler"
  Jeweler::Tasks.new do |gem|
    gem.name = "custom_fields"
    gem.summary = "Custom fields plugin for Mongoid"
    gem.authors = ['Didier Lafforgue']
    gem.email = ['didier@nocoffee.fr']
    gem.date = Date.today
    gem.description = "Manage custom fields to a mongoid document or a collection. This module is one of the core features we implemented in our custom cms named Locomotive."
    gem.homepage = %q{http://github.com/locomotivecms/custom_fields}
    gem.files = Dir[
      "init.rb",
      "{lib}/**/*"]
  end
  Jeweler::GemcutterTasks.new
rescue Exception => e
  puts "Jeweler or one of its dependencies is not installed. #{e.inspect}"
end