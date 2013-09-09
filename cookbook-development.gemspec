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

  spec.add_dependency 'berkshelf', '~> 2.0'
  spec.add_dependency 'bundler', '~> 1.3'
  spec.add_dependency 'chef', '~> 11.6'
  spec.add_dependency 'chefspec', '~> 1.3'
  spec.add_dependency 'foodcritic', '~> 2.2'
  # Workaround for json dependency for chef and berkshelf.  Chef
  # wants <= 1.7.7 and berkshelf >= 1.5 but bundler tries to grab 1.8.0
  # which violates chef's requirement.  Seems like a bundler bug.
  spec.add_dependency 'json', '1.7.7'
  spec.add_dependency 'kitchen-vagrant', "~> 0.11"
  spec.add_dependency 'rake', '~> 10.0'
  spec.add_dependency 'strainer', '~> 3.0'
  spec.add_dependency 'test-kitchen', '1.0.0.beta.3'
  spec.add_dependency 'version', '~> 1.0'
end
