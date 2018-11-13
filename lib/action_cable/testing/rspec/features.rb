# frozen_string_literal: true

# Use async adapter for features specs by deafault
RSpec.configure do |config|
  config.include_context "action_cable:async", type: [:feature, :system]
end
