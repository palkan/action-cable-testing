# frozen_string_literal: true

source "https://rubygems.org"

# Specify your gem's dependencies in action-cable-testing.gemspec
gemspec

gem "rails", "~> 5.2"

gem "pry-byebug"

local_gemfile = "Gemfile.local"

if File.exist?(local_gemfile)
  eval(File.read(local_gemfile)) # rubocop:disable Security/Eval
end
