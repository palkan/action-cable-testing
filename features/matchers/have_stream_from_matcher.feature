Feature: have_stream_from matcher

  The `have_stream_from` matcher is used to check if a channel has been subscribed to a given stream specified as a String.
  If you use `stream_for` in you channel to subscribe to a model, use `have_stream_for` matcher instead.

  The `have_no_streams` matcher is used to check if a channe hasn't been subscribed to any stream.

  It is available only in channel specs.

  Background:
    Given action cable is available

  Scenario: subscribing with params and checking streams
      Given a file named "spec/channels/chat_channel_spec.rb" with:
      """ruby
      require "rails_helper"

      RSpec.describe ChatChannel, :type => :channel do
        it "successfully subscribes" do
          stub_connection user_id: 42
          subscribe(room_id: 1)

          expect(subscription).to be_confirmed
          expect(subscription).to have_stream_from("chat_1")
        end
      end
      """
      When I run `rspec spec/channels/chat_channel_spec.rb`
      Then the example should pass

    Scenario: subscribing and checking streams for models
      Given a file named "spec/channels/user_channel_spec.rb" with:
      """ruby
      require "rails_helper"
      RSpec.describe UserChannel, :type => :channel do
        it "successfully subscribes" do
          subscribe(id: 42)
          expect(subscription).to be_confirmed
          expect(subscription).to have_stream_for(User.new(42))
        end
      end
      """
      When I run `rspec spec/channels/user_channel_spec.rb`
      Then the example should pass

    Scenario: stopping all streams
      Given a file named "spec/channels/chat_channel_spec.rb" with:
        """ruby
        require "rails_helper"

        RSpec.describe ChatChannel, :type => :channel do
          it "successfully subscribes" do
            stub_connection user_id: 42
            subscribe(room_id: 1)

            expect(subscription).to have_stream_from("chat_1")

            perform :leave
            expect(subscription).not_to have_streams
          end
        end
        """
      When I run `rspec spec/channels/chat_channel_spec.rb`
      Then the example should pass
