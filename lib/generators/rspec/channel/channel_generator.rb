# frozen_string_literal: true

require "generators/rspec"

module Rspec
  module Generators
    # @private
    class ChannelGenerator < Base
      source_root File.expand_path("../templates", __FILE__)

      def create_channel_spec
        template "channel_spec.rb.erb", File.join("spec/channels", class_path, "#{file_name}_channel_spec.rb")
      end
    end
  end
end
