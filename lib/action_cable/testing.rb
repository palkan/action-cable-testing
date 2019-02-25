# frozen_string_literal: true

require "action_cable/testing/version"

require "action_cable"
require "action_cable/testing/rails_six"

module ActionCable
  autoload :TestCase
  autoload :TestHelper

  module Channel
    eager_autoload do
      autoload :TestCase
    end
  end

  module Connection
    eager_autoload do
      autoload :TestCase
    end
  end

  module SubscriptionAdapter
    autoload :Test
  end
end
