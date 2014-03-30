# encoding: utf-8

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'correlation_attack/version'

Gem::Specification.new do |spec|
  spec.name          = "correlation_attack"
  spec.version       = CorrelationAttack::VERSION
  spec.authors       = ["Thomas Brus"]
  spec.email         = ["thomas.brus@me.com"]
  spec.homepage      = "http://github.com/thomasbrus/correlation-attack"
  spec.summary       = "Nice DSL for executing correlation attacks"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake", "~> 10.2.2"
  spec.add_development_dependency "yard", "~> 0.8.7.3"
end
