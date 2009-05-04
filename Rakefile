require 'rake'
require 'spec/rake/spectask'

task :default => :spec

desc "Run all functional specs"
Spec::Rake::SpecTask.new(:spec_functional) do |t|
  t.spec_opts = ['--options', "\"#{File.dirname(__FILE__)}/spec/spec.opts\""]
  t.spec_files = FileList['spec/*_spec.rb']
end

desc "Run all unit specs"
Spec::Rake::SpecTask.new(:spec_unit) do |t|
  t.spec_opts = ['--options', "\"#{File.dirname(__FILE__)}/spec/spec.opts\""]
  t.spec_files = FileList['spec/unit/*_spec.rb']
end

desc "Run all specs"
task :spec => [:spec_unit, :spec_functional] do
end

begin
  require 'jeweler'
  Jeweler::Tasks.new do |s|
    s.name = "couch_potato"
    s.summary = %Q{Ruby persistence layer for CouchDB}
    s.email = "alex@upstream-berlin.com"
    s.homepage = "http://github.com/langalex/couch_potato"
    s.description = "Ruby persistence layer for CouchDB"
    s.authors = ["Alexander Lang"]
    s.files = FileList["[A-Z]*.*", "{lib,spec,rails}/**/*", "init.rb"]
    s.add_dependency 'json'
    s.add_dependency 'validatable'
    s.add_dependency 'couchrest', '>=0.24'
  end
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install technicalpickles-jeweler -s http://gems.github.com"
end
