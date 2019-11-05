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

  spec.add_dependency 'berkshelf', "= 7.0.8"
  spec.add_dependency 'bundler'
  spec.add_dependency 'chef', "= 14.12.9"
  spec.add_dependency 'chefspec', "= 7.2.1"
  spec.add_dependency 'cookstyle'
  spec.add_dependency 'dep_selector'
  spec.add_dependency 'dbus-systemd'
  spec.add_dependency 'foodcritic'
  spec.add_dependency 'guard'
  spec.add_dependency 'guard-rspec'
  spec.add_dependency 'guard-foodcritic'
  spec.add_dependency 'guard-rubocop'
  spec.add_dependency 'inspec', "= 1.51.0"
  spec.add_dependency 'kitchen-inspec'
  spec.add_dependency 'kitchen-docker'
  spec.add_dependency 'kitchen-dokken'
  spec.add_dependency 'kitchen-google'
  spec.add_dependency 'kitchen-vagrant'
  spec.add_dependency 'knife-ec2'
  spec.add_dependency 'pry-coolline'
  spec.add_dependency 'rake'
  spec.add_dependency 'ridley'
  spec.add_dependency 'rspec-its'
  spec.add_dependency 'semverse'
  spec.add_dependency 'test-kitchen'
  spec.add_dependency 'thor-scmversion'
  spec.add_dependency 'version'

end
