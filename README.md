[![Gem Version](https://badge.fury.io/rb/action-cable-testing.svg)](https://rubygems.org/gems/action-cable-testing) [![Build Status](https://travis-ci.org/palkan/action-cable-testing.svg?branch=master)](https://travis-ci.org/palkan/action-cable-testing) [![Yard Docs](http://img.shields.io/badge/yard-docs-blue.svg)](http://www.rubydoc.info/gems/action-cable-testing)

# Action Cable Testing

This gem provides missing testing utils for [Action Cable][].

**NOTE:** this gem [has](https://github.com/rails/rails/pull/33659) [been](https://github.com/rails/rails/pull/33969) [merged](https://github.com/rails/rails/pull/34845) into Rails 6.0 and [into RSpec 4](https://github.com/rspec/rspec-rails/pull/2113).

If you're using Minitest – you don't need this gem anymore.

If you're using RSpec < 4, you still can use this gem to write Action Cable specs even for Rails 6.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'action-cable-testing'
```

And then execute:

    $ bundle

## Usage

### Test Adapter and Broadcasting

We add `ActionCable::SubscriptionAdapter::Test` (very similar Active Job and Action Mailer tests adapters) and `ActionCable::TestCase` with a couple of matchers to track broadcasting messages in our tests:

```ruby
# Using ActionCable::TestCase
class MyCableTest < ActionCable::TestCase
  def test_broadcasts
    # Check the number of messages broadcasted to the stream
    assert_broadcasts 'messages', 0
    ActionCable.server.broadcast 'messages', { text: 'hello' }
    assert_broadcasts 'messages', 1

    # Check the number of messages broadcasted to the stream within a block
    assert_broadcasts('messages', 1) do
      ActionCable.server.broadcast 'messages', { text: 'hello' }
    end

    # Check that no broadcasts has been made
    assert_no_broadcasts('messages') do
      ActionCable.server.broadcast 'another_stream', { text: 'hello' }
    end
  end
end

# Or including ActionCable::TestHelper
class ExampleTest < ActionDispatch::IntegrationTest
  include ActionCable::TestHelper

  def test_broadcasts
    room = rooms(:office)

    assert_broadcast_on("messages:#{room.id}", text: 'Hello!') do
      post "/say/#{room.id}", xhr: true, params: { message: 'Hello!' }
    end
  end
end
```

If you want to test the broadcasting made with `Channel.broadcast_to`, you should use
`Channel.broadcasting_for`\* to generate an underlying stream name and **use Rails 6 compatibility refinement**:

```ruby
# app/jobs/chat_relay_job.rb
class ChatRelayJob < ApplicationJob
  def perform_later(room, message)
    ChatChannel.broadcast_to room, text: message
  end
end


# test/jobs/chat_relay_job_test.rb
require "test_helper"

# Activate Rails 6 compatible API (for `broadcasting_for`)
using ActionCable::Testing::Rails6

class ChatRelayJobTest < ActiveJob::TestCase
  include ActionCable::TestHelper

  test "broadcast message to room" do
    room = rooms(:all)

    assert_broadcast_on(ChatChannel.broadcasting_for(room), text: "Hi!") do
      ChatRelayJob.perform_now(room, "Hi!")
    end
  end
end
```

\* **NOTE:** in Rails 6.0 you should use `.broadcasting_for`, but it's not backward compatible
and we cannot use it in Rails 5.x. See https://github.com/rails/rails/pull/35021.
Note also, that this feature hasn't been released in Rails 6.0.0.beta1, so you still need the refinement.

### Channels Testing

Channels tests are written as follows:
1. First, one uses the `subscribe` method to simulate subscription creation.
2. Then, one asserts whether the current state is as expected. "State" can be anything:
transmitted messages, subscribed streams, etc.

For example:

```ruby
class ChatChannelTest < ActionCable::Channel::TestCase
  def test_subscribed_with_room_number
    # Simulate a subscription creation
    subscribe room_number: 1

    # Asserts that the subscription was successfully created
    assert subscription.confirmed?

    # Asserts that the channel subscribes connection to a stream
    assert_has_stream "chat_1"

    # Asserts that the channel subscribes connection to a stream created with `stream_for`
    assert_has_stream_for Room.find(1)
  end
  
  def test_subscribed_without_room_number
    subscribe
    
    assert subscription.confirmed?
    # Asserts that no streams was started
    # (e.g., we want to subscribe later by performing an action)
    assert_no_streams
  end

  def test_does_not_subscribe_with_invalid_room_number
    subscribe room_number: -1

    # Asserts that the subscription was rejected
    assert subscription.rejected?
  end
end
```

You can also perform actions:

```ruby
def test_perform_speak
  subscribe room_number: 1

  perform :speak, message: "Hello, Rails!"

  # `transmissions` stores messages sent directly to the channel (i.e. with `transmit` method)
  assert_equal "Hello, Rails!", transmissions.last["text"]
end
```

You can set up your connection identifiers:

```ruby
class ChatChannelTest < ActionCable::Channel::TestCase
  include ActionCable::TestHelper

  def test_identifiers
    stub_connection(user: users[:john])

    subscribe room_number: 1

    assert_broadcast_on("messages_1", text: "I'm here!", from: "John") do
      perform :speak, message: "I'm here!"
    end
  end
end
```
When broadcasting to an object:

```ruby
class ChatChannelTest < ActionCable::Channel::TestCase
  def setup
    @room = Room.find 1

    stub_connection(user: users[:john])
    subscribe room_number: room.id
  end

  def test_broadcasting
    assert_broadcasts(@room, 1) do
      perform :speak, message: "I'm here!"
    end
  end

  # or

  def test_broadcasted_data
    assert_broadcast_on(@room, text: "I'm here!", from: "John") do
      perform :speak, message: "I'm here!"
    end
  end
end
```

### Connection Testing

Connection unit tests are written as follows:
1. First, one uses the `connect` method to simulate connection.
2. Then, one asserts whether the current state is as expected (e.g. identifiers).

For example:

```ruby
module ApplicationCable
  class ConnectionTest < ActionCable::Connection::TestCase
    def test_connects_with_cookies
      cookies.signed[:user_id] = users[:john].id

      # Simulate a connection
      connect

      # Asserts that the connection identifier is correct
      assert_equal "John", connection.user.name
    end

    def test_does_not_connect_without_user
      assert_reject_connection do
        connect
      end
    end
  end
end
```

You can also provide additional information about underlying HTTP request:

```ruby
def test_connect_with_headers_and_query_string
  connect "/cable?user_id=1", headers: { "X-API-TOKEN" => 'secret-my' }

  assert_equal connection.user_id, "1"
end

def test_connect_with_session
  connect "/cable", session: { users[:john].id }

  assert_equal connection.user_id, "1"
end
```

### RSpec Usage

First, you need to have [rspec-rails](https://github.com/rspec/rspec-rails) installed.

Second, add this to your `"rails_helper.rb"` after requiring `environment.rb`:

```ruby
require "action_cable/testing/rspec"
```

To use `have_broadcasted_to` / `broadcast_to` matchers anywhere in your specs, set your adapter to `test` in `cable.yml`:

```yml
# config/cable.yml
test:
  adapter: test
```

And then use these matchers, for example:


```ruby
RSpec.describe CommentsController do
  describe "POST #create" do
    expect { post :create, comment: { text: 'Cool!' } }.to
      have_broadcasted_to("comments").with(text: 'Cool!')
  end
end
```

Or when broacasting to an object:

```ruby
RSpec.describe CommentsController do
  describe "POST #create" do
    let(:the_post) { create :post }

    expect { post :create, comment: { text: 'Cool!', post_id: the_post.id } }.to
      have_broadcasted_to(the_post).from_channel(PostChannel).with(text: 'Cool!')
  end
end
```

You can also unit-test your channels:


```ruby
# spec/channels/chat_channel_spec.rb

require "rails_helper"

RSpec.describe ChatChannel, type: :channel do
  before do
    # initialize connection with identifiers
    stub_connection user_id: user.id
  end
  
  it "subscribes without streams when no room id" do
    subscribe

    expect(subscription).to be_confirmed
    expect(subscription).not_to have_streams
  end

  it "rejects when room id is invalid" do
    subscribe(room_id: -1)

    expect(subscription).to be_rejected
  end

  it "subscribes to a stream when room id is provided" do
    subscribe(room_id: 42)

    expect(subscription).to be_confirmed

    # check particular stream by name
    expect(subscription).to have_stream_from("chat_42")

    # or directly by model if you create streams with `stream_for`
    expect(subscription).to have_stream_for(Room.find(42))
  end
end
```

And, of course, connections:

```ruby
require "rails_helper"

RSpec.describe ApplicationCable::Connection, type: :channel do
  it "successfully connects" do
    connect "/cable", headers: { "X-USER-ID" => "325" }
    expect(connection.user_id).to eq "325"
  end

  it "rejects connection" do
    expect { connect "/cable" }.to have_rejected_connection
  end
end
```

**NOTE:** for connections testing you must use `type: :channel` too.

#### Shared contexts to switch between adapters

**NOTE:** this feature is gem-only and hasn't been migrated to RSpec 4. You can still use the gem for that by adding `require "rspec/rails/shared_contexts/action_cable"` to your `rspec_helper.rb`.

Sometimes you may want to use _real_ Action Cable adapter instead of the test one (for example, in Capybara-like tests).

We provide shared contexts to do that:

```ruby
# Use async adapter for this example group only
RSpec.describe "cable case", action_cable: :async do
 # ...

  context "inline cable", action_cable: :inline do
    # ...
  end

  # or test adapter
  context "test cable", action_cable: :test do
    # ...
  end

  # you can also include contexts by names
  context "by name" do
    include "action_cable:async"
    # ...
  end
end
```

We also provide an integration for _feature_ specs (having `type: :feature`). Just add `require "action_cable/testing/rspec/features"`:

```ruby
# rails_helper.rb
require "action_cable/testing/rspec"
require "action_cable/testing/rspec/features"

# spec/features/my_feature_spec.rb
feature "Cables!" do
  # here we have "action_cable:async" context included automatically!
end
```

For more RSpec documentation see https://relishapp.com/palkan/action-cable-testing/docs.

### Generators

This gem also provides Rails generators:

```sh
# Generate a channel test case for ChatChannel
rails generate test_unit:channel chat

# or for RSpec
rails generate rspec:channel chat
```

## Development

After checking out the repo, run `bundle install` to install dependencies. Then, run `bundle exec rake` to run the tests.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/palkan/action-cable-testing.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

[Action Cable]: http://guides.rubyonrails.org/action_cable_overview.html
