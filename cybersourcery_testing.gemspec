$:.push File.expand_path('../lib', __FILE__)

# Maintain your gem's version:
require 'cybersourcery_testing/version'

Gem::Specification.new do |spec|
  spec.name          = 'cybersourcery_testing'
  spec.version       = CybersourceryTesting::VERSION
  spec.authors       = ['Michael Toppa']
  spec.email         = ['public@toppa.com']
  spec.summary       = %q{For developing feature tests with Cybersourcery}
  spec.description   = %q{The Cybersourcery Testing gem is designed for use with Rails projects, and supports feature/integration testing of the Cybersource Silent Order POST (SOP) service. It can be used with the Cybersourcery gem or as a stand-alone testing service. It uses a Sinatra proxy server and VCR, to avoid the need for repeated requests to the Cybersource SOP test server.}
  spec.homepage      = 'https://github.com/promptworks/cybersourcery_testing'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'rack-translating_proxy', '>= 0.1.1'
  spec.add_dependency 'sinatra', '>= 1.4'
  spec.add_dependency 'nokogiri', '>= 1.6'
  spec.add_dependency 'webmock', '>= 1.19'
  spec.add_dependency 'vcr', '>= 2.9'
  spec.add_dependency 'rakeup', '>= 1.2'
  spec.add_dependency 'dotenv', '>= 0.11'
  spec.add_development_dependency 'bundler', '>= 1.6'
  spec.add_development_dependency 'rake', '>= 10.3'
end
