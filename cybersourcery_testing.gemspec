# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cybersourcery_testing/version'

Gem::Specification.new do |spec|
  spec.name          = "cybersourcery_testing"
  spec.version       = CybersourceryTesting::VERSION
  spec.authors       = ["Michael Toppa"]
  spec.email         = ["public@toppa.com"]
  spec.summary       = %q{For developing feature tests with Cybersourcery}
  spec.description   = %q{}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'rack-translating_proxy'
  spec.add_dependency 'sinatra'
  spec.add_dependency 'nokogiri'
  spec.add_dependency 'webmock'
  spec.add_dependency 'vcr'
  spec.add_dependency 'shotgun'
  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
end
