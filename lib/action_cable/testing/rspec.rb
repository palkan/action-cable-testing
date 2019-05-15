# frozen_string_literal: true

require "action-cable-testing"
require "rspec/rails"

if RSpec::Rails::FeatureCheck.respond_to?(:has_action_cable_testing?)
  warn <<~MSG
    You're using RSpec with Action Cable support.

    You can remove `require "action_cable/testing/rspec"` from your RSpec setup.

    NOTE: if you use Action Cable shared contexts ("action_cable:async", "action_cable:inline", etc.)
    you still need to use the gem and add `require "rspec/rails/shared_contexts/action_cable"`.
  MSG
else
  require "rspec/rails/example/channel_example_group"
  require "rspec/rails/matchers/action_cable"

  module RSpec # :nodoc:
    module Rails
      module FeatureCheck
        module_function
          def has_action_cable_testing?
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
end

require "rspec/rails/shared_contexts/action_cable"
