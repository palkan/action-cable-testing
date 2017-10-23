require "spec_helper"

module RSpec::Rails
  describe ChannelExampleGroup do
    if defined?(ActionCable)
      it_behaves_like "an rspec-rails example group mixin", :channel,
        './spec/channels/', '.\\spec\\channels\\'
    end
  end
end
