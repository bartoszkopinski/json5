require 'v8'
require 'oj'
require 'json5'
require 'rspec/autorun'

RSpec.configure do |config|
  config.color = true
  config.filter_run focus: true
  config.filter_run_excluding skip: true
  config.mock_with :rspec
  config.order = 'random'
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true
  config.profile_examples = true
end
