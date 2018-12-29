$LOAD_PATH.push File.expand_path('../lib', __FILE__)
require 'couch_potato/version'

Gem::Specification.new do |s|
  s.name = 'couch_potato-rspec'
  s.summary = 'RSpec matchers for Couch Potato'
  s.email = 'alex@upstre.am'
  s.homepage = 'http://github.com/langalex/couch_potato'
  s.description = 'RSpec matchers for Couch Potato'
  s.authors = ['Alexander Lang']
  s.version     = CouchPotato::RSPEC_VERSION
  s.platform    = Gem::Platform::RUBY

  s.add_dependency 'rspec', '~>3.4'
  s.add_development_dependency 'rake'
  s.add_dependency 'execjs', '~>2.7.0'

  s.files         = `git ls-files | grep "lib/couch_potato/rspec\|vendor/pouchdb-collate"`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/* | grep rspec_matchers`.split("\n")
  s.require_paths = ['lib']
end
