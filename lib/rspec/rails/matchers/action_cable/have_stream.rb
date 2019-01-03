# rubocop: disable Style/FrozenStringLiteralComment

module RSpec
  module Rails
    module Matchers
      module ActionCable
        class HaveStream < RSpec::Matchers::BuiltIn::BaseMatcher
          AnyStream = Class.new do
            def self.to_s
              " "
            end
          end

          def initialize(stream = AnyStream)
            @stream = stream
          end

          def failure_message
            "expected to have #{base_message}"
          end

          def failure_message_when_negated
            "expected not to have #{base_message}"
          end

          def supports_block_expectations?
            false
          end

          def matches?(subscription)
            case subscription
            when ::ActionCable::Channel::Base
              @streams = subscription.streams
              any_stream? ? @streams.any? : @streams.include?(@stream)
            else
              raise ArgumentError, "have_stream, have_stream_from and have_stream_from support expectations on subscription only"
            end
          end

        private

          def base_message
            any_stream? ? "any stream started" : "stream #{@stream} started, but have #{@streams}"
          end

          def any_stream?
            @stream == AnyStream
          end
        end
      end
    end
  end
end
