lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'stevedore/version'

Gem::Specification.new do |s|
  s.name        = 'stevedore'
  s.version     = Stevedore::VERSION
  s.licenses    = ['MIT']
  s.authors     = ['M Innovations']
  s.email       = ['contact@minnovations.sg']
  s.homepage    = 'https://github.com/minnovations/stevedore'
  s.summary     = 'Containerized app development workflow helper'
  s.description = 'Stevedore is a handy helper to make developing and deploying apps with Docker
containers a little easier.'

  s.required_ruby_version = '>= 2.0.0'

  s.files = `git ls-files`.split($/)

  s.bindir        = 'exe'
  s.executables   = ['steve']
  s.require_paths = ['lib']

  s.add_dependency 'aws-sdk', '~> 2.5'
  s.add_dependency 'dotenv', '~> 2.1'
end
