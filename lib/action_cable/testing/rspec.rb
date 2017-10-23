# frozen_string_literal: true

module RSpec
  module Rails
    module FeatureCheck
      module_function
        def has_action_cable?
          defined?(::ActionCable)
        end
    end
  end
end
