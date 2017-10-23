Feature: channel spec
  
  Channel specs are marked by `:type => :channel` or if you have set
  `config.infer_spec_type_from_file_location!` by placing them in `spec/channels`.

  A channel spec is a thin wrapper for an ActionCable::Channel::TestCase, and includes all
  of the behavior and assertions that it provides, in addition to RSpec's own
  behavior and expectations.

  Background:
    Given action cable is available

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
