This gem provides missing testing utils for [Action Cable][].

**NOTE:** this gem is just a combination of two PRs to Rails itself ([#23211](https://github.com/rails/rails/pull/23211) and [#27191](https://github.com/rails/rails/pull/27191)) and (hopefully) will be merged into Rails eventually.

**NOTE 2:** this is the documentation for (mostly) RSpec part of the gem. For Minitest usage see the repo's [Readme](https://github.com/palkan/action-cable-testing) or [Minitest Usage](minitest) chapter.

## Installation

Add this line to your application's Gemfile:

```ruby
group :test, :development do
  gem 'action-cable-testing'
end
```

And then execute:

    $ bundle


## Issues

Bug reports and pull requests are welcome on GitHub at https://github.com/palkan/action-cable-testing.

[Action Cable]: http://guides.rubyonrails.org/action_cable_overview.html