require 'rake'
require 'spec/rake/spectask'
require 'rake/rdoctask'

def with_validatable(&block)
  begin
    require 'validatable'
    
    ENV['VALIDATION_FRAMEWORK'] = 'validatable'
    puts "Running task with Validatable validation framework."
    yield block
  rescue LoadError
    STDERR.puts "WARNING: Validatable not available, skipping task."
  end
end

def with_active_model(&block)
  begin
    require 'active_model'
    
    ENV['VALIDATION_FRAMEWORK'] = 'active_model'
    puts "Running task with ActiveModel validation framework."
    yield block
  rescue LoadError
    STDERR.puts "WARNING: ActiveModel not available, skipping task."
  end
end

task :default => :spec

task :spec_functional_validatable do
  with_validatable { Rake::Task['spec_functional_default'].execute }
end

task :spec_functional_active_model do
  with_active_model { Rake::Task['spec_functional_default'].execute }
end

task :spec_unit_validatable do
  with_validatable { Rake::Task['spec_unit_default'].execute }
end

task :spec_unit_active_model do
  with_active_model { Rake::Task['spec_unit_default'].execute }
end

desc "Run functional specs with default validation framework, override with VALIDATION_FRAMEWORK"
Spec::Rake::SpecTask.new(:spec_functional_default) do |t|
  t.spec_opts = ['--options', "\"#{File.dirname(__FILE__)}/spec/spec.opts\""]
  t.spec_files = FileList['spec/*_spec.rb']
end

desc "Run unit specs with default validation framework, override with VALIDATION_FRAMEWORK"
Spec::Rake::SpecTask.new(:spec_unit_default) do |t|
  t.spec_opts = ['--options', "\"#{File.dirname(__FILE__)}/spec/spec.opts\""]
  t.spec_files = FileList['spec/unit/*_spec.rb']
end

desc "Run functional specs with all validation frameworks"
task :spec_functional => [:spec_functional_validatable, :spec_functional_active_model] do
end

desc "Run unit specs with all validation frameworks"
task :spec_unit => [:spec_unit_validatable, :spec_unit_active_model] do
end

desc "Run all specs"
task :spec => [:spec_unit, :spec_functional] do
end

desc 'Generate documentation'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'Couch Potato'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README.md')
  rdoc.rdoc_files.include('lib/couch_potato.rb')
  rdoc.rdoc_files.include('lib/couch_potato/**/*.rb')
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
