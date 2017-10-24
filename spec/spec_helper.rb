# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)

begin
  require "pry-byebug"
rescue LoadError
end

require "action_controller/railtie"
require "action_view/railtie"
require "action_cable"

require "action_cable/testing/rspec"

require "ammeter/init"

# Require all the stubs and models
Dir[File.expand_path("../test/stubs/*.rb", __dir__)].each { |file| require file }

# # Set test adapter and logger
ActionCable.server.config.cable = { "adapter" => "test" }
ActionCable.server.config.logger =
  ActiveSupport::TaggedLogging.new ActiveSupport::Logger.new(StringIO.new)

Dir[File.expand_path("support/**/*.rb", __dir__)].each { |f| require f }

RSpec.configure do |config|
  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.example_status_persistence_file_path = "tmp/rspec_examples.txt"
  config.filter_run :focus
  config.run_all_when_everything_filtered = true

  config.order = :random
  Kernel.srand config.seed
end
