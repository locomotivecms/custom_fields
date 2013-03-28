#!/usr/bin/env bundle
# encoding: utf-8

source :rubygems

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
    gem 'debugger'
  end
end
