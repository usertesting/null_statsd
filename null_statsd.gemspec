# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'null_statsd/version'

Gem::Specification.new do |spec|
  spec.name          = "null_statsd"
  spec.version       = NullStatsd::VERSION
  spec.authors       = ["Imad Mouaddine"]
  spec.email         = ["imouaddine@usertesting.com"]

  spec.summary       = %q{Implements null pattern for Statsd client}
  spec.description   = %q{Implements null pattern for Statsd client}
  spec.homepage      = "https://www.usertesting.com"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
