# frozen_string_literal: true

require "action-cable-testing"
require "rspec/rails"
require "rspec/rails/example/channel_example_group"
require "rspec/rails/matchers/action_cable"
require "rspec/rails/shared_contexts/action_cable"

module RSpec # :nodoc:
  module Rails
    module FeatureCheck
      module_function
        def has_action_cable?
          defined?(::ActionCable)
        end
    end

    self::DIRECTORY_MAPPINGS[:channel] = %w[spec channels]
  end
end

RSpec.configure do |config|
  if defined?(ActionCable)
    config.include RSpec::Rails::ChannelExampleGroup, type: :channel
  end
end
