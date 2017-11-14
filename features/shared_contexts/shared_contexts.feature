Feature: action cable shared contexts
  
  Sometimes you may want to use _real_ Action Cable adapter instead of the test one (for example, 
  in Capybara-like tests).

  We provide shared contexts to do that.

  Background:
    Given action cable is available

  Scenario: using tags to set async adapter
    Given a file named "spec/models/broadcaster_spec.rb" with:
    """ruby
    require "rails_helper"

    RSpec.describe Broadcaster, action_cable: :async do
      it "uses async adapter" do
        expect(ActionCable.server.pubsub).to be_a(ActionCable::SubscriptionAdapter::Async)
      end
    end
    """
    When I run `rspec spec/models/broadcaster_spec.rb`
    Then the example should pass

  Scenario: using shared context to set async adapter
    Given a file named "spec/models/broadcaster_spec.rb" with:
    """ruby
    require "rails_helper"

    RSpec.describe Broadcaster do
      context "with async cable" do
        include_context "action_cable:async"

        it "uses async adapter" do
          expect(ActionCable.server.pubsub).to be_a(ActionCable::SubscriptionAdapter::Async)
        end
      end
    end
    """
    When I run `rspec spec/models/broadcaster_spec.rb`
    Then the example should pass

  Scenario: using tags to set inline adapter
    Given a file named "spec/models/broadcaster_spec.rb" with:
    """ruby
    require "rails_helper"

    RSpec.describe Broadcaster, action_cable: :inline do
      it "uses inline adapter" do
        expect(ActionCable.server.pubsub).to be_a(ActionCable::SubscriptionAdapter::Inline)
      end
    end
    """
    When I run `rspec spec/models/broadcaster_spec.rb`
    Then the example should pass

  Scenario: require features specs setup
    Given a file named "spec/models/broadcaster_spec.rb" with:
    """ruby
    require "rails_helper"
    require "action_cable/testing/rspec/features"

    RSpec.describe Broadcaster, type: :feature do
      it "uses async adapter for feature specs" do
        expect(ActionCable.server.pubsub).to be_a(ActionCable::SubscriptionAdapter::Async)
      end
    end
    """
    When I run `rspec spec/models/broadcaster_spec.rb`
    Then the example should pass
