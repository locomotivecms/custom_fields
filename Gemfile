#!/usr/bin/env bundle
# encoding: utf-8

source 'https://rubygems.org'

gemspec # Include gemspec dependencies

gem 'rake'

platforms :mri_18 do
  unless ENV['CI']
    gem 'ruby-debug'
  end
  gem 'SystemTimer'
end

platforms :mri_19 do
  unless ENV['CI']
    gem 'ruby-debug19', :require => 'ruby-debug', :platforms => :mri_19 if RUBY_VERSION < '1.9.3'
  end
end