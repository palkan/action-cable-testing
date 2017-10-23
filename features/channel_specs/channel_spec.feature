Feature: channel spec

  Background:
    Given action cable is available

  @rails_post_5
  Scenario: simple passing example
    Given a file named "spec/channels/chat_channel_spec.rb" with:
    """ruby
    require "rails_helper"

    RSpec.describe ChatChannel, :type => :channel do
      it "successfully subscribes" do
        subscribe
        expect(subscription).to be_confirmed
      end
    end
    """
    When I run `rspec spec/channels/chat_channel_spec.rb`
    Then the example should pass
