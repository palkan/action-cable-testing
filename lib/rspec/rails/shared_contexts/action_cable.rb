# frozen_string_literal: true

# Generate contexts to use specific Action Cable adapter:
# - "action_cable:async" (action_cable: :async)
# - "action_cable:inline" (action_cable: :inline)
# - "action_cable:test" (action_cable: :test)
%w[async inline test].each do |adapter|
  RSpec.shared_context "action_cable:#{adapter}" do
    require "action_cable/subscription_adapter/#{adapter}"

    adapter_class = ActionCable::SubscriptionAdapter.const_get(adapter.capitalize)

    before do
      next if ActionCable.server.pubsub.is_a?(adapter_class)

      @__was_pubsub_adapter__ = ActionCable.server.pubsub

      adapter = adapter_class.new(ActionCable.server)
      ActionCable.server.instance_variable_set(:@pubsub, adapter)
    end

    after do
      next unless instance_variable_defined?(:@__was_pubsub_adapter__)
      ActionCable.server.instance_variable_set(:@pubsub, @__was_pubsub_adapter__)
    end
  end

  RSpec.configure do |config|
    config.include_context "action_cable:#{adapter}", action_cable: adapter.to_sym
  end
end
