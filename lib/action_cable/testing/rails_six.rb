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
      begin
        # Has been added only after 6.0.0.beta1
        unless ActionCable::Channel::Base.respond_to?(:serialize_broadcasting)
          refine ActionCable::Channel::Broadcasting::ClassMethods do
            def broadcasting_for(model)
              super([channel_name, model])
            end
          end
        end

        SUPPORTED = true
      rescue TypeError
        warn "Your Ruby version doesn't suppport Module refinements. " \
             "Rails 6 compatibility refinement could not be applied"

        SUPPORTED = false
      end
    end
  end
end
