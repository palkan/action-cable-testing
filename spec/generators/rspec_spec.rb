# frozen_string_literal: true

require "spec_helper"
require "generators/rspec/channel/channel_generator"

describe Rspec::Generators::ChannelGenerator, type: :generator do
  destination File.expand_path("../../../tmp", __FILE__)

  let(:args) { ["chat"] }

  before do
    prepare_destination
    run_generator(args)
  end

  subject { file("spec/channels/chat_channel_spec.rb") }

  it "creates script", :aggregate_failures do
    is_expected.to exist
    is_expected.to contain("require 'rails_helper'")
    is_expected.to contain("RSpec.describe ChatChannel, type: :channel")
  end
end
