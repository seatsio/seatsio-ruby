
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "seatsio/version"

Gem::Specification.new do |spec|
  spec.name          = "seatsio"
  spec.version       = Seatsio::VERSION
  spec.authors       = ["Seats.io"]
  spec.email         = ["nahuel@seats.io"]

  spec.summary       = "the official Seats.io Ruby client library"
  spec.description   = "This is the official Ruby client library for the Seats.io V2 REST API"
  spec.homepage      = "http://seats.io"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "rest-client", "~> 2.0.2"
  spec.add_development_dependency "simplecov", "~> 0.6.1"
end
