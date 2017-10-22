# frozen_string_literal: true

require "spec_helper"
require "generators/test_unit/channel/channel_generator"

describe TestUnit::Generators::ChannelGenerator, type: :generator do
  destination File.expand_path("../../../tmp", __FILE__)

  let(:args) { ["chat"] }

  before do
    prepare_destination
    run_generator(args)
  end

  subject { file("test/channels/chat_channel_test.rb") }

  it "creates script", :aggregate_failures do
    is_expected.to exist
    is_expected.to contain("class ChatChannelTest < ActionCable::TestCase")
  end
end
