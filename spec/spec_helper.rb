require 'bundler/setup'
require 'simplecov'

root = File.expand_path '../../', __FILE__

lib = File.expand_path 'lib', root
$:.unshift lib unless $:.include? lib

require 'custom_fields'

# Requires supporting ruby files with custom matchers and macros, etc. in `spec/support` and its subdirectories.
support = File.expand_path 'spec/support', root

Dir["#{support}/**/*.rb"].each { |file| require file }

# Requires supporting ruby files with custom models in `spec/models` and its subdirectories.
models = File.expand_path 'spec/models', root

Dir["#{models}/**/*.rb"].each { |file| require file }

# Conventionally, all specs live under a `spec` directory, which RSpec adds to the `$LOAD_PATH`. The generated `.rspec`
# file contains `--require spec_helper` which will cause this file to always be loaded, without a need to explicitly
# require it in any files.
#
# Given that it is always loaded, you are encouraged to keep this file as light-weight as possible. Requiring
# heavyweight dependencies from this file will add to the boot time of your test suite on EVERY test run, even for an
# individual file that may not need all of that loaded. Instead, make a separate helper file that requires this one and
# then use it only in the specs that actually need it.
RSpec.configure do |config|
  # These two settings work together to allow you to limit a spec run to individual examples or groups you care about by
  # tagging them with `:focus` metadata. When nothing is tagged with `:focus`, all examples get run.
  config.filter_run :focus
  config.run_all_when_everything_filtered = true

  # Many RSpec users commonly either run the entire suite or an individual file, and it's useful to allow more verbose
  # output when running an individual spec file.
  if config.files_to_run.one?
    # Use the documentation formatter for detailed output, unless a formatter has already been configured (e.g. via a
    # command-line flag).
    config.default_formatter = :doc
  end

  # Print the 10 slowest examples and example groups at the end of the spec run, to help surface which specs are running
  # particularly slow.
  config.profile_examples = 10

  # Run specs in random order to surface order dependencies. If you find an order dependency and want to debug it, you
  # can fix the order by providing the seed, which is printed after each run (`--seed <seed-id>`).
  config.order = :random

  # Seed global randomization in this process using the `--seed` CLI option. Setting this allows you to use `--seed` to
  # deterministically reproduce test failures related to randomization by passing the same `--seed` value as the one
  # that triggered the failure.
  Kernel.srand config.seed

  # Configure Mocha as mock framework.
  config.mock_framework = :mocha

  # RSpec Expectations configuration
  config.expect_with :rspec do |expectations|
    expectations.syntax = :expect # Use the “expect” syntax
  end

  config.backtrace_exclusion_patterns = [
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
