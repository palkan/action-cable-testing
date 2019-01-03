# rubocop: disable Style/FrozenStringLiteralComment

module RSpec
  module Rails
    module Matchers
      module ActionCable
        class HaveStream < RSpec::Matchers::BuiltIn::BaseMatcher
          AnyStream = Object.new.freeze

          def initialize(stream = AnyStream)
            @expected = stream
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
              @actual = subscription.streams
              any_stream? ? actual.any? : actual.include?(expected)
            else
              raise ArgumentError, "have_stream, have_stream_from and have_stream_from support expectations on subscription only"
            end
          end

        private

          def base_message
            any_stream? ? "any stream started" : "stream #{expected_formatted} started, but have #{actual_formatted}"
          end

          def any_stream?
            expected == AnyStream
          end
        end
      end
    end
  end
end
