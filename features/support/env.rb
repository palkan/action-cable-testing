require "aruba/cucumber"
require "fileutils"

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
