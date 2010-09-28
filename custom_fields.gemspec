lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require "custom_fields/version"

Gem::Specification.new do |s|
  s.name        = "locomotive_cms"
  s.version     = Mongoid::CustomFields::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Didier Lafforgue"]
  s.email       = ["didier@nocoffee.fr"]
  s.homepage    = "http://github.com/locomotivecms/custom_fields"
  s.summary     = "Custom fields extension for Mongoid"
  s.description = "Manage custom fields to a mongoid document or a collection. This module is one of the core features we implemented in our custom cms named Locomotive."

  s.required_rubygems_version = ">= 1.3.6"
  s.rubyforge_project         = "nowarning"

  s.add_dependency 'mongoid', '>= 2.0.0.beta.18'
  s.add_dependency 'activesupport', '>= 3.0.0'
  s.add_dependency 'carrierwave'

  s.files        = Dir[ "init.rb",
                        "MIT-LICENSE",
                        "README",
                        "{lib}/**/*"]

  s.require_path = 'lib'

  s.extra_rdoc_files = [
    "MIT-LICENSE",
    "README"
  ]

end