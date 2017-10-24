This gem provides missing testing utils for [Action Cable][].

**NOTE:** this gem is just a combination of two PRs to Rails itself ([#23211](https://github.com/rails/rails/pull/23211) and [#27191](https://github.com/rails/rails/pull/27191)) and (hopefully) will be merged into Rails eventually.

**NOTE 2:** this is the documentation for (mostly) RSpec part of the gem. For Minitest usage see the repo's [Readme](https://github.com/palkan/action-cable-testing) or [Minitest Usage](minitest) chapter.

## Installation

Add this line to your application's Gemfile:

```ruby
group :test, :development do
  gem 'action-cable-testing'
end
```

And then execute:

    $ bundle

## Basic Usage

First, set your adapter to `test` in `cable.yml`:

```yml
# config/cable.yml
test:
  adapter: test
```

Now you can use `have_broadcasted_to` / `broadcast_to` matchers anywhere in your specs. For example:

```ruby
RSpec.describe CommentsController do
  describe "POST #create" do
    expect { post :create, comment: { text: 'Cool!' } }.to
      have_broadcasted_to("comments").with(text: 'Cool!')
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

  it "rejects when no room id" do
    subscribe
    expect(subscription).to be_rejected
  end

  it "subscribes to a stream when room id is provided" do
    subscribe(room_id: 42)

    expect(subscription).to be_confirmed
    expect(streams).to include("chat_42")
  end
end
```

## Issues

Bug reports and pull requests are welcome on GitHub at https://github.com/palkan/action-cable-testing.

[Action Cable]: http://guides.rubyonrails.org/action_cable_overview.html