require 'support/simpleconv.rb'

require 'rubygems'
require 'bundler'
Bundler.setup
Bundler.require

require 'rspec'
require 'pry'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[File.dirname(__FILE__) + "/support/**/*.rb"].each { |f| require f }

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), "..", "lib"))

MODELS = File.join(File.dirname(__FILE__), 'models')
$LOAD_PATH.unshift(MODELS)

NAMESPACED_MODELS = File.join(File.dirname(__FILE__), 'models', 'namespaced')
$LOAD_PATH.unshift(NAMESPACED_MODELS)

require 'custom_fields'

Dir[File.join(MODELS, "*.rb")].sort.each { |file| require File.basename(file) }
Dir[File.join(NAMESPACED_MODELS, "*.rb")].sort.each { |file| require File.basename(file) }

RSpec.configure do |config|
  config.mock_with :mocha

  require 'database_cleaner'
  require 'database_cleaner/mongoid/truncation'

  config.backtrace_clean_patterns = [
    /\/lib\d*\/ruby\//,
    /bin\//,
    /gems/,
    /spec\/spec_helper\.rb/,
    /lib\/rspec\/(core|expectations|matchers|mocks)/
  ]

  config.before(:suite) do
    DatabaseCleaner['mongoid'].strategy = :truncation
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
    ::I18n.locale = 'en'
    Mongoid::Fields::I18n.locale = 'en'
  end
end
