# frozen_string_literal: true

require "rails/generators/test_unit"

module TestUnit # :nodoc:
  module Generators # :nodoc:
    class ChannelGenerator < Base # :nodoc:
      source_root File.expand_path("../templates", __FILE__)

      check_class_collision suffix: "ChannelTest"

      def create_test_file
        template "unit_test.rb.erb", File.join("test/channels", class_path, "#{file_name}_channel_test.rb")
      end
    end
  end
end
