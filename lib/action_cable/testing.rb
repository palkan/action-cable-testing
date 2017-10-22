# frozen_string_literal: true

require "action_cable/testing/version"

require "action_cable"

module ActionCable
  autoload :TestCase
  autoload :TestHelper

  module SubscriptionAdapter
    autoload :Test
  end
end
