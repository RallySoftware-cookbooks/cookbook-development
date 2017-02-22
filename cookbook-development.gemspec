# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cookbook/development/version'

Gem::Specification.new do |spec|
  spec.name          = 'cookbook-development'
  spec.version       = Cookbook::Development::VERSION
  spec.authors       = ['Rally Software Development Corp']
  spec.email         = ['rallysoftware-cookbooks@rallydev.com']
  spec.description   = %q{Rally Software Development Corp cookbook development}
  spec.summary       = %q{Rally Software Development Corp cookbook development}
  spec.homepage      = ''
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'berkshelf'
  spec.add_dependency 'bundler', '~> 1.10'
  spec.add_dependency 'chef', '~> 12.3'
  spec.add_dependency 'chefspec', '~> 4.2'
  spec.add_dependency 'knife-ec2', '~> 0.10'
  spec.add_dependency 'foodcritic', '~> 5.0'
  spec.add_dependency 'kitchen-vagrant', '~> 0.18'
  spec.add_dependency 'rake', '~> 10.4'
  spec.add_dependency 'test-kitchen'
  spec.add_dependency 'version', '~> 1.0'
  spec.add_dependency 'thor-scmversion', '~> 1.7'
  spec.add_dependency 'kitchen-docker'
  spec.add_dependency 'semverse'
  spec.add_dependency 'ridley'
  spec.add_dependency 'rspec-its'

end
