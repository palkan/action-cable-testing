Feature: channel spec

  Channel specs are marked by `:type => :channel` or if you have set
  `config.infer_spec_type_from_file_location!` by placing them in `spec/channels`.

  A channel spec is a thin wrapper for an ActionCable::Channel::TestCase, and includes all
  of the behavior and assertions that it provides, in addition to RSpec's own
  behavior and expectations.

  It also includes helpers from ActionCable::Connection::TestCase to make it possible to
  test connection behavior.

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
        expect(subscription).to have_stream_from("chat_1")
      end
    end
    """
    When I run `rspec spec/channels/chat_channel_spec.rb`
    Then the example should pass

  Scenario: subscribing with params and checking stream presence
    Given a file named "spec/channels/chat_channel_spec.rb" with:
    """ruby
    require "rails_helper"

    RSpec.describe ChatChannel, :type => :channel do
      it "successfully subscribes" do
        stub_connection user_id: 42
        subscribe(room_id: 1)

        expect(subscription).to be_confirmed
        expect(subscription).to have_stream
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
        expect(subscription).not_to have_stream
      end
    end
    """
    When I run `rspec spec/channels/chat_channel_spec.rb`
    Then the example should pass

  Scenario: successful connection with url params
    Given a file named "spec/channels/connection_spec.rb" with:
    """ruby
    require "rails_helper"

    RSpec.describe ApplicationCable::Connection, :type => :channel do
      it "successfully connects" do
        connect "/cable?user_id=323"
        expect(connection.user_id).to eq "323"
      end
    end
    """
    When I run `rspec spec/channels/connection_spec.rb`
    Then the example should pass

  Scenario: successful connection with cookies
    Given a file named "spec/channels/connection_spec.rb" with:
    """ruby
    require "rails_helper"

    RSpec.describe ApplicationCable::Connection, :type => :channel do
      it "successfully connects" do
        connect "/cable", cookies: { user_id: "324" }
        expect(connection.user_id).to eq "324"
      end
    end
    """
    When I run `rspec spec/channels/connection_spec.rb`
    Then the example should pass

  Scenario: successful connection with session
    Given a file named "spec/channels/connection_spec.rb" with:
    """ruby
    require "rails_helper"

    RSpec.describe ApplicationCable::Connection, :type => :channel do
      it "successfully connects" do
        connect "/cable", session: { user_id: "324" }
        expect(connection.user_id).to eq "324"
      end
    end
    """
    When I run `rspec spec/channels/connection_spec.rb`
    Then the example should pass

  Scenario: successful connection with headers
    Given a file named "spec/channels/connection_spec.rb" with:
    """ruby
    require "rails_helper"

    RSpec.describe ApplicationCable::Connection, :type => :channel do
      it "successfully connects" do
        connect "/cable", headers: { "X-USER-ID" => "325" }
        expect(connection.user_id).to eq "325"
      end
    end
    """
    When I run `rspec spec/channels/connection_spec.rb`
    Then the example should pass

  Scenario: rejected connection
    Given a file named "spec/channels/connection_spec.rb" with:
    """ruby
    require "rails_helper"

    RSpec.describe ApplicationCable::Connection, :type => :channel do
      it "rejects connection" do
        expect { connect "/cable" }.to have_rejected_connection
      end
    end
    """
    When I run `rspec spec/channels/connection_spec.rb`
    Then the example should pass

  Scenario: disconnect connection
    Given a file named "spec/channels/connection_spec.rb" with:
    """ruby
    require "rails_helper"

    RSpec.describe ApplicationCable::Connection, :type => :channel do
      it "disconnects" do
        connect "/cable?user_id=42"
        expect { disconnect }.to output(/User 42 disconnected/).to_stdout
      end
    end
    """
    When I run `rspec spec/channels/connection_spec.rb`
    Then the example should pass
