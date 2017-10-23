# Copied from rspec-rails

module Helpers
  include RSpec::Rails::FeatureCheck

  def with_isolated_config
    original_config = RSpec.configuration
    RSpec.configuration = RSpec::Core::Configuration.new
    RSpec::Rails.initialize_configuration(RSpec.configuration)

    if defined?(ActionCable)
      RSpec.configure do |config|
        config.include RSpec::Rails::ChannelExampleGroup, type: :channel
      end
    end

    yield RSpec.configuration
  ensure
    RSpec.configuration = original_config
  end

  RSpec.configure { |c| c.include self }
end
