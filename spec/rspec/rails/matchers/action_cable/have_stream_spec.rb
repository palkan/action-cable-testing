require "spec_helper"
require "rspec/rails/feature_check"

module FakeChannelHelper
  extend ActiveSupport::Concern

  module ClassMethods
    # @private
    def channel_class
      Class.new(ActionCable::Channel::Base) do
        def subscribed
          stream_from "chat_#{params[:id]}" if params[:id]
          stream_for User.new(params[:user]) if params[:user]
        end

        def self.channel_name
          "broadcast"
        end
      end
    end
  end
end

RSpec.describe "have_stream matchers" do
  include RSpec::Rails::ChannelExampleGroup
  include FakeChannelHelper

  before { stub_connection }

  describe "have_stream" do
    it "raises when no subscription started" do
      expect {
        expect(subscription).to have_stream
      }.to raise_error(/Must be subscribed!/)
    end

    it "raises ArgumentError when no subscription passed to expect" do
      subscribe id: 1

      expect {
        expect(true).to have_stream
      }.to raise_error(ArgumentError)
    end

    it "passes" do
      subscribe id: 1

      expect(subscription).to have_stream
    end

    it "fails with message" do
      subscribe

      expect {
        expect(subscription).to have_stream
      }.to raise_error(/expected to have any stream started/)
    end

    context "with negated form" do
      it "passes with negated form" do
        subscribe

        expect(subscription).not_to have_stream
      end

      it "fails with message" do
        subscribe id: 1

        expect {
          expect(subscription).not_to have_stream
        }.to raise_error(/expected not to have any stream started/)
      end
    end
  end

  describe "have_stream_from" do
    it "raises when no subscription started" do
      expect {
        expect(subscription).to have_stream_from("stream")
      }.to raise_error(/Must be subscribed!/)
    end

    it "raises ArgumentError when no subscription passed to expect" do
      subscribe id: 1

      expect {
        expect(true).to have_stream_from("stream")
      }.to raise_error(ArgumentError)
    end

    it "passes" do
      subscribe id: 1

      expect(subscription).to have_stream_from("chat_1")
    end

    it "fails with message" do
      subscribe id: 1

      expect {
        expect(subscription).to have_stream_from("chat_2")
      }.to raise_error(/expected to have stream chat_2 started, but have \[\"chat_1\"\]/)
    end

    context "with negated form" do
      it "passes" do
        subscribe id: 1

        expect(subscription).not_to have_stream_from("chat_2")
      end

      it "fails with message" do
        subscribe id: 1

        expect {
          expect(subscription).not_to have_stream_from("chat_1")
        }.to raise_error(/expected not to have stream chat_1 started, but have \[\"chat_1\"\]/)
      end
    end
  end

  describe "have_stream_for" do
    it "raises when no subscription started" do
      expect {
        expect(subscription).to have_stream_for(User.new(42))
      }.to raise_error(/Must be subscribed!/)
    end

    it "raises ArgumentError when no subscription passed to expect" do
      subscribe user: 42

      expect {
        expect(true).to have_stream_for(User.new(42))
      }.to raise_error(ArgumentError)
    end

    it "passes" do
      subscribe user: 42

      expect(subscription).to have_stream_for(User.new(42))
    end

    it "fails with message" do
      subscribe user: 42

      expect {
        expect(subscription).to have_stream_for(User.new(31337))
      }.to raise_error(/expected to have stream broadcast:User#31337 started, but have \[\"broadcast:User#42\"\]/)
    end

    context "with negated form" do
      it "passes" do
        subscribe user: 42

        expect(subscription).not_to have_stream_for(User.new(31337))
      end

      it "fails with message" do
        subscribe user: 42

        expect {
          expect(subscription).not_to have_stream_for(User.new(42))
        }.to raise_error(/expected not to have stream broadcast:User#42 started, but have \[\"broadcast:User#42\"\]/)
      end
    end
  end
end
