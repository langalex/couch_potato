require 'rubygems'
Gem::manage_gems
require 'rake/gempackagetask'
spec = Gem::Specification.new do |s|
    s.name      =   "couch_potato"
    s.version   =   "0.1"
    s.author    =   "Alexander Lang"
    s.email     =   "alex @nospam@ upstream-berlin.com"
    s.homepage  = 'http://github.com/langalex/couch_potato'
    s.summary   =   "a couchdb persistence layer in ruby"
    s.files     =   FileList['lib/**/*.rb', 'spec/*', 'init.rb', 'Readme.textile', 'MIT-LICENSE.txt', 'CREDITS'].to_a
    s.require_paths  <<  "lib"
end
