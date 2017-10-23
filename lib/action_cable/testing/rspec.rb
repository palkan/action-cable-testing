# frozen_string_literal: true

require "rspec/rails/example/channel_example_group"

module RSpec
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
