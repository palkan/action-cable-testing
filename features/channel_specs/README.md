Channel specs are marked by `:type => :channel` or if you have set
`config.infer_spec_type_from_file_location!` by placing them in `spec/channels`.

A channel spec is a thin wrapper for an ActionCable::Channel::TestCase, and includes all
of the behavior and assertions that it provides, in addition to RSpec's own
behavior and expectations.
