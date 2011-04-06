require 'bundler'
Bundler::GemHelper.install_tasks

require 'rake'
require "rspec/core/rake_task"
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
RSpec::Core::RakeTask.new(:spec_functional_default) do |spec|
  spec.pattern = 'spec/*_spec.rb'
  spec.rspec_opts = ['--options', "\"#{File.dirname(__FILE__)}/spec/spec.opts\""]
end

desc "Run unit specs with default validation framework, override with VALIDATION_FRAMEWORK"
RSpec::Core::RakeTask.new(:spec_unit_default) do |spec|
  spec.pattern = 'spec/unit/*_spec.rb'
  spec.rspec_opts = ['--options', "\"#{File.dirname(__FILE__)}/spec/spec.opts\""]
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
