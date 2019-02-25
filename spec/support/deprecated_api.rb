DeprecatedApi = Module.new do
  def self.enabled?
    ActionCable::VERSION::MAJOR < 6 && (
      Gem::Version.new(ActionCable::Testing::VERSION) < Gem::Version.new("1.0") ||
        raise("Deprecated API should be removed")
    )
  end
end
