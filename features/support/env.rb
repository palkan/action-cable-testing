require "aruba/cucumber"
require 'fileutils'

# module ArubaExt
#   def run(cmd, timeout = nil)
#     exec_cmd = cmd =~ /^rspec/ ? "bin/#{cmd}" : cmd
#     super(exec_cmd, timeout)
#   end
#   # This method over rides Aruba 0.5.4 implementation so that we can reset Bundler to use the sample app Gemfile
#   def in_current_dir(&block)
#     Bundler.with_clean_env do
#       _mkdir(current_dir)
#       Dir.chdir(current_dir, &block)
#     end
#   end
# end

# World(ArubaExt)

Before do
  @aruba_timeout_seconds = 30
end

Before do
  example_app_dir = "spec/dummy"
  aruba_dir = "tmp/aruba"

  # Remove the previous aruba workspace.
  FileUtils.rm_rf(aruba_dir) if File.exist?(aruba_dir)
  FileUtils.cp_r(example_app_dir, aruba_dir)
end
