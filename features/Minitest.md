[Full Documentation](http://www.rubydoc.info/gems/action-cable-testing)

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

    # Asserts that the channel subscribes connection to a specific
    # stream created for a model
    assert_has_stream_for Room.find(1)
  end

  def test_does_not_stream_with_incorrect_room_number
    subscribe room_number: -1

    # Asserts that not streams was started
    assert_no_streams
  end

  def test_does_not_subscribe_without_room_number
    subscribe

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
  include ActionCable::TestHelper

  def setup
    @room = Room.find 1

    stub_connection(user: users[:john])
    subscribe room_number: room.id
  end

  def test_broadcating
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

### Generators

This gem also provides Rails generators:

```sh
# Generate a channel test case for ChatChannel
rails generate test_unit:channel chat
```
