# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "couch_potato/version"

Gem::Specification.new do |s|
  s.name = "couch_potato"
  s.summary = %Q{Ruby persistence layer for CouchDB}
  s.email = "alex@upstre.am"
  s.homepage = "http://github.com/langalex/couch_potato"
  s.description = "Ruby persistence layer for CouchDB"
  s.authors = ["Alexander Lang"]
  s.version     = CouchPotato::VERSION
  s.platform    = Gem::Platform::RUBY

  s.add_dependency 'json', '~> 1.6.0'
  s.add_dependency 'couchrest', '>=1.0.1'
  s.add_dependency 'activemodel'
  s.add_dependency 'therubyracer'

  s.add_development_dependency 'rspec', '>=2.0'
  s.add_development_dependency 'timecop'
  s.add_development_dependency 'tzinfo'
  s.add_development_dependency 'rake'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
