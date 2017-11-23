# rubocop: disable Style/FrozenStringLiteralComment

module RSpec
  module Rails
    module Matchers
      # Namespace for various implementations of ActionCable features
      #
      # @api private
      module ActionCable
        # rubocop: disable Style/ClassLength
        # @private
        class HaveBroadcastedTo < RSpec::Matchers::BuiltIn::BaseMatcher
          def initialize(stream, streaming_channel:)
            @stream = stream
            @streaming_channel = streaming_channel
            @block = Proc.new {}
            set_expected_number(:exactly, 1)
          end

          def with(data = nil)
            @data = data
            @data = @data.with_indifferent_access if @data.is_a?(Hash)
            @block = Proc.new if block_given?
            self
          end

          def exactly(count)
            set_expected_number(:exactly, count)
            self
          end

          def at_least(count)
            set_expected_number(:at_least, count)
            self
          end

          def at_most(count)
            set_expected_number(:at_most, count)
            self
          end

          def times
            self
          end

          def once
            exactly(:once)
          end

          def twice
            exactly(:twice)
          end

          def thrice
            exactly(:thrice)
          end

          def failure_message
            "expected to broadcast #{base_message}".tap do |msg|
              if @unmatching_msgs.any?
                msg << "\nBroadcasted messages to #{stream}:"
                @unmatching_msgs.each do |data|
                  msg << "\n  #{data}"
                end
              end
            end
          end

          def failure_message_when_negated
            "expected not to broadcast #{base_message}"
          end

          def message_expectation_modifier
            case @expectation_type
            when :exactly then "exactly"
            when :at_most then "at most"
            when :at_least then "at least"
            end
          end

          def supports_block_expectations?
            true
          end

          def matches?(proc)
            raise ArgumentError, "have_broadcasted_to and broadcast_to only support block expectations" unless Proc === proc

            original_sent_messages_count = pubsub_adapter.broadcasts(stream).size
            proc.call
            in_block_messages = pubsub_adapter.broadcasts(stream).drop(original_sent_messages_count)

            check(in_block_messages)
          end

          def from_channel(channel)
            unless callable_stream?
              warn "`from_channel` works only when broadcasting to object"
            end

            @streaming_channel = channel
            self
          end

        private

          def stream
            callable_stream? ? @stream.call(@streaming_channel) : @stream
          end

          def check(messages)
            @matching_msgs, @unmatching_msgs = messages.partition do |msg|
              decoded = ActiveSupport::JSON.decode(msg)
              decoded = decoded.with_indifferent_access if decoded.is_a?(Hash)

              if @data.nil? || @data === decoded
                @block.call(decoded)
                true
              else
                false
              end
            end

            @matching_msgs_count = @matching_msgs.size

            case @expectation_type
            when :exactly then @expected_number == @matching_msgs_count
            when :at_most then @expected_number >= @matching_msgs_count
            when :at_least then @expected_number <= @matching_msgs_count
            end
          end

          def set_expected_number(relativity, count)
            @expectation_type = relativity
            @expected_number =
              case count
              when :once then 1
              when :twice then 2
              when :thrice then 3
              else Integer(count)
              end
          end

          def base_message
            "#{message_expectation_modifier} #{@expected_number} messages to #{stream}".tap do |msg|
              msg << " with #{data_description(@data)}" unless @data.nil?
              msg << ", but broadcast #{@matching_msgs_count}"
            end
          end

          def data_description(data)
            if data.is_a?(RSpec::Matchers::Composable)
              data.description
            else
              data
            end
          end

          def pubsub_adapter
            ::ActionCable.server.pubsub
          end

          def callable_stream?
            @stream.respond_to?(:call)
          end
        end
        # rubocop: enable Style/ClassLength
      end

      # @api public
      # Passes if a message has been sent to a stream/object inside a block.
      # May chain `at_least`, `at_most` or `exactly` to specify a number of times.
      # To specify channel from which message has been broadcasted to object use `from_channel`.
      #
      #
      # @example
      #     expect {
      #       ActionCable.server.broadcast "messages", text: 'Hi!'
      #     }.to have_broadcasted_to("messages")
      #
      #     expect {
      #       SomeChannel.broadcast_to(user)
      #     }.to have_broadcasted_to(user).from_channel(SomeChannel)
      #
      #     # Using alias
      #     expect {
      #       ActionCable.server.broadcast "messages", text: 'Hi!'
      #     }.to broadcast_to("messages")
      #
      #     expect {
      #       ActionCable.server.broadcast "messages", text: 'Hi!'
      #       ActionCable.server.broadcast "all", text: 'Hi!'
      #     }.to have_broadcasted_to("messages").exactly(:once)
      #
      #     expect {
      #       3.times { ActionCable.server.broadcast "messages", text: 'Hi!' }
      #     }.to have_broadcasted_to("messages").at_least(2).times
      #
      #     expect {
      #       ActionCable.server.broadcast "messages", text: 'Hi!'
      #     }.to have_broadcasted_to("messages").at_most(:twice)
      #
      #     expect {
      #       ActionCable.server.broadcast "messages", text: 'Hi!'
      #     }.to have_broadcasted_to("messages").with(text: 'Hi!')

      def have_broadcasted_to(target = nil)
        check_action_cable_adapter

        stream = stream_for(target)
        ActionCable::HaveBroadcastedTo.new(stream, streaming_channel: described_class)
      end
      alias_method :broadcast_to, :have_broadcasted_to

    private

      # @private
      def check_action_cable_adapter
        return if ::ActionCable::SubscriptionAdapter::Test === ::ActionCable.server.pubsub
        raise StandardError, "To use ActionCable matchers set `adapter: :test` in your cable.yml"
      end

      def stream_for(target)
        if target.is_a?(String)
          target
        else
          -> channel { channel.broadcasting_for([channel.channel_name, target]) }
        end
      end
    end
  end
end
