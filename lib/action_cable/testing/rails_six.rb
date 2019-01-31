# frozen_string_literal: true

module ActionCable
  module Testing
    # Enables Rails 6 compatible API via Refinements.
    #
    # Use this to write Rails 6 compatible tests (not every Rails 6 API
    # could be backported).
    #
    # Usage:
    #   # my_test.rb
    #   require "test_helper"
    #
    #   using ActionCable::Testing::Syntax
    module Rails6
      refine ActionCable::Channel::Broadcasting::ClassMethods do
        def broadcasting_for(model)
          super([channel_name, model])
        end
      end
    end
  end
end
