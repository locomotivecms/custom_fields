#!/usr/bin/env bundle
# encoding: utf-8

source :rubygems

gemspec # Include gemspec dependencies

group :development do
  gem 'carrierwave', :git => 'git://github.com/jnicklas/carrierwave.git' # Until version 0.6.0 gets released
  
  unless ENV['CI']
    gem 'ruby-debug', :platforms => :mri_18

    gem 'ruby-debug19', :require => 'ruby-debug', :platforms => :mri_19 if RUBY_VERSION < '1.9.3'
  end
end