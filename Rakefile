# frozen_string_literal: true

require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "rubocop/rake_task"
require "rake/testtask"

Rake::TestTask.new do |t|
  t.test_files = FileList["test/**/*_test.rb"]
end

RuboCop::RakeTask.new
RSpec::Core::RakeTask.new(:spec)

task default: [:rubocop, :spec, :test]
