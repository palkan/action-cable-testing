Feature: channel spec

  Background:
    Given action cable is available

  @rails_post_5
  Scenario: simple passing example
    Given a file named "spec/channels/echo_channel_spec.rb" with:
    """ruby
    require "rails_helper"

    RSpec.describe EchoChannel, :type => :channel do
      it "successfully subscribes" do
        subscribe
        expect(subscription).to be_confirmed
      end
    end
    """
    When I run `rspec spec/channels/echo_channel_spec.rb`
    Then the example should pass

  @rails_post_5
  Scenario: verifying that subscription is rejected
    Given a file named "spec/channels/chat_channel_spec.rb" with:
    """ruby
    require "rails_helper"

    RSpec.describe ChatChannel, :type => :channel do
      it "rejects subscription" do
        stub_connection user_id: nil
        subscribe
        expect(subscription).to be_rejected
      end
    end
    """
    When I run `rspec spec/channels/chat_channel_spec.rb`
    Then the example should pass

  @rails_post_5
  Scenario: specifying connection identifiers
    Given a file named "spec/channels/chat_channel_spec.rb" with:
    """ruby
    require "rails_helper"

    RSpec.describe ChatChannel, :type => :channel do
      it "successfully subscribes" do
        stub_connection user_id: 42
        subscribe
        expect(subscription).to be_confirmed
        expect(subscription.user_id).to eq 42
      end
    end
    """
    When I run `rspec spec/channels/chat_channel_spec.rb`
    Then the example should pass


  @rails_post_5
  Scenario: subscribing with params and checking streams
    Given a file named "spec/channels/chat_channel_spec.rb" with:
    """ruby
    require "rails_helper"

    RSpec.describe ChatChannel, :type => :channel do
      it "successfully subscribes" do
        stub_connection user_id: 42
        subscribe(room_id: 1)

        expect(subscription).to be_confirmed
        expect(streams).to include("chat_1")
      end
    end
    """
    When I run `rspec spec/channels/chat_channel_spec.rb`
    Then the example should pass

  @rails_post_5
  Scenario: performing actions and checking transmissions
    Given a file named "spec/channels/echo_channel_spec.rb" with:
    """ruby
    require "rails_helper"

    RSpec.describe EchoChannel, :type => :channel do
      it "successfully subscribes" do
        subscribe

        perform :echo, foo: 'bar'
        expect(transmissions.last).to eq('foo' => 'bar')
      end
    end
    """
    When I run `rspec spec/channels/echo_channel_spec.rb`
    Then the example should pass
