# frozen_string_literal: true

module RSpec
  module Rails
    # @api public
    # Container module for channel spec functionality. It is only available if
    # ActionCable has been loaded before it.
    module ChannelExampleGroup
      # This blank module is only necessary for YARD processing. It doesn't
      # handle the conditional `defined?` check below very well.
    end
  end
end

if defined?(ActionCable)
  module RSpec
    module Rails
      # Container module for channel spec functionality.
      module ChannelExampleGroup
        extend ActiveSupport::Concern
        include RSpec::Rails::RailsExampleGroup
        include ActionCable::Channel::TestCase::Behavior

        # Class-level DSL for channel specs.
        module ClassMethods
          # @private
          def channel_class
            described_class
          end
        end
      end
    end
  end
end
