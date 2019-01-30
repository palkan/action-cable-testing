# frozen_string_literal: true

require "action_cable/testing/version"

require "action_cable"

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

# Add `Channel.broadcasting_name_for` to backport Rails 6
# `Channel.broadcasting_for` without breaking anything
ActionCable::Channel::Broadcasting::ClassMethods.include(Module.new do
  def broadcasting_name_for(model)
    broadcasting_for([ channel_name, model ])
  end
end)
