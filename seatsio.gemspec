
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

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "rest-client", '~> 2.0', '>= 2.0.2'

  spec.add_development_dependency "bundler", "~> 2.2"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency 'webmock', '~> 3.4', '>= 3.4.2'
  spec.add_development_dependency 'parallel_tests', '~> 4.7.1'
end
