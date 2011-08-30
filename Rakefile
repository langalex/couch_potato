require 'bundler'
Bundler::GemHelper.install_tasks

require 'rake'
require "rspec/core/rake_task"
require 'rake/rdoctask'

task :default => :spec

desc "Run functional specs"
RSpec::Core::RakeTask.new(:spec_functional) do |spec|
  spec.pattern = 'spec/*_spec.rb'
  spec.rspec_opts = ['--options', "\"#{File.dirname(__FILE__)}/spec/spec.opts\""]
end

desc "Run unit specs"
RSpec::Core::RakeTask.new(:spec_unit) do |spec|
  spec.pattern = 'spec/unit/*_spec.rb'
  spec.rspec_opts = ['--options', "\"#{File.dirname(__FILE__)}/spec/spec.opts\""]
end

desc "Run all specs"
task :spec do
  ['3_0', '3_1'].each do |version|
    Bundler.with_clean_env do
      ENV['BUNDLE_GEMFILE'] = "active_support_#{version}"
      sh "bundle install"
      Rake::Task[:spec_unit_active_model].execute
      Rake::Task[:spec_functional_active_model].execute
      Rake::Task[:spec_unit_validatable].execute
      Rake::Task[:spec_functional_validatable].execute
    end
  end
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
