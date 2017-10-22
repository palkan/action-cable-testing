# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)

require "pry-byebug"

require "action_cable"
require "action-cable-testing"

require "active_support/testing/autorun"

# Require all the stubs and models
Dir[File.expand_path("stubs/*.rb", __dir__)].each { |file| require file }

# # Set test adapter and logger
ActionCable.server.config.cable = { "adapter" => "test" }
ActionCable.server.config.logger =
  ActiveSupport::TaggedLogging.new ActiveSupport::Logger.new(StringIO.new)
