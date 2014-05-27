# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rapportive/version'

Gem::Specification.new do |spec|
  spec.name          = "rapportive"
  spec.version       = Rapportive::VERSION
  spec.authors       = ["jkuchar"]
  spec.email         = ["jakub.kuchar@hotmail.com"]
  spec.summary       = %q{Rapportive email lookup by first name, last name, domain}
  spec.description   = %q{Rapportive email lookup by first name, last name, domain based on node.js example}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"

  spec.add_runtime_dependency "em-synchrony"
  spec.add_runtime_dependency "em-http-request"
  spec.add_runtime_dependency "httparty"
  spec.add_runtime_dependency "faraday"
  spec.add_runtime_dependency "faraday_middleware"
end
