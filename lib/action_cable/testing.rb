# frozen_string_literal: true

require "action_cable/testing/version"

require "action_cable"
require "action_cable/testing/rails_six"

# These has been merged into Rails 6
unless ActionCable::VERSION::MAJOR >= 6
  require "action_cable/testing/test_helper"
  require "action_cable/testing/test_case"

  require "action_cable/testing/channel/test_case"

  require "action_cable/testing/connection/test_case"

  # We cannot move subsription adapter under 'testing/' path,
  # 'cause Action Cable uses this path when resolving an
  # adapter from its name (in the config.yml)
  require "action_cable/subscription_adapter/test"
end
