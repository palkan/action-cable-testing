Feature: have_broadcasted matcher

  The `have_broadcasted_to` (also aliased as `broadcast_to`) matcher is used to check if a message has been broadcasted to a given stream.

  Background:
    Given action cable is available

  Scenario: Checking stream name
    Given a file named "spec/models/broadcaster_spec.rb" with:
      """ruby
      require "rails_helper"

      RSpec.describe Broadcaster do
        it "matches with stream name" do
          expect {
            ActionCable.server.broadcast(
              "notifications", text: 'Hello!'
            )
          }.to have_broadcasted_to("notifications")
        end
      end
      """
    When I run `rspec spec/models/broadcaster_spec.rb`
    Then the examples should all pass

  Scenario: Checking passed message to stream
    Given a file named "spec/models/broadcaster_spec.rb" with:
      """ruby
      require "rails_helper"

      RSpec.describe Broadcaster do
        it "matches with message" do
          expect {
            ActionCable.server.broadcast(
              "notifications", text: 'Hello!'
            )
          }.to have_broadcasted_to("notifications").with(text: 'Hello!')
        end
      end
      """
    When I run `rspec spec/models/broadcaster_spec.rb`
    Then the examples should all pass


  Scenario: Checking that message passed to stream matches
    Given a file named "spec/models/broadcaster_spec.rb" with:
      """ruby
      require "rails_helper"

      RSpec.describe Broadcaster do
        it "matches with message" do
          expect {
            ActionCable.server.broadcast(
              "notifications", text: 'Hello!', user_id: 12
            )
          }.to have_broadcasted_to("notifications").with(a_hash_including(text: 'Hello!'))
        end
      end
      """
    When I run `rspec spec/models/broadcaster_spec.rb`
    Then the examples should all pass

  Scenario: Checking passed message with block
    Given a file named "spec/models/broadcaster_spec.rb" with:
      """ruby
      require "rails_helper"

      RSpec.describe Broadcaster do
        it "matches with message" do
          expect {
            ActionCable.server.broadcast(
              "notifications", text: 'Hello!', user_id: 12
            )
          }.to have_broadcasted_to("notifications").with { |data|
            expect(data['user_id']).to eq 12
          }
        end
      end
      """
    When I run `rspec spec/models/broadcaster_spec.rb`
    Then the examples should all pass

  Scenario: Using alias method
    Given a file named "spec/models/broadcaster_spec.rb" with:
      """ruby
      require "rails_helper"

      RSpec.describe Broadcaster do
        it "matches with stream name" do
          expect {
            ActionCable.server.broadcast(
              "notifications", text: 'Hello!'
            )
          }.to broadcast_to("notifications")
        end
      end
      """
    When I run `rspec spec/models/broadcaster_spec.rb`
    Then the examples should all pass
