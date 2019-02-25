# frozen_string_literal: true

require_relative "test_helper"

using ActionCable::Testing::Rails6

class BroadcastChannel < ActionCable::Channel::Base
end

class TransmissionsTest < ActionCable::TestCase
  def test_broadcasting_for_name
    skip unless ActionCable::Testing::Rails6::SUPPORTED

    user = User.new(42)

    assert_nothing_raised do
      assert_broadcasts BroadcastChannel.broadcasting_for(user), 1 do
        BroadcastChannel.broadcast_to user, text: "text"
      end
    end
  end
end
