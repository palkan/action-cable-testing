# frozen_string_literal: true

lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require "action_cable/testing/version"

Gem::Specification.new do |spec|
  spec.name          = "action-cable-testing"
  spec.version       = ActionCable::Testing::VERSION

  spec.authors       = ["Vladimir Dementyev"]
  spec.email         = ["dementiev.vm@gmail.com"]

  spec.summary       = "Testing utils for Action Cable"
  spec.description   = "Testing utils for Action Cable"
  spec.homepage      = "http://github.com/palkan/action-cable-testing"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/).select { |p| p.match(%r{^lib/}) } +
    %w(README.md CHANGELOG.md LICENSE.txt)

  spec.require_paths = ["lib"]

  spec.required_ruby_version = ">= 2.3.0"

  spec.add_dependency "actioncable", ">= 5.0"

  spec.add_development_dependency "bundler", ">= 1.10"
  spec.add_development_dependency "cucumber", "~> 3.1.1"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec-rails", "~> 3.5"
  spec.add_development_dependency "aruba", "~> 0.14.6"
  spec.add_development_dependency "minitest", "~> 5.9"
  spec.add_development_dependency "ammeter", "~> 1.1"
  spec.add_development_dependency "rubocop", "~> 0.72.0"
end
