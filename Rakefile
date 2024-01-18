require 'bundler'
Bundler::GemHelper.install_tasks name: 'couch_potato'

require 'rake'
require 'rspec/core/rake_task'

task default: :spec

desc 'Run functional specs'
RSpec::Core::RakeTask.new(:spec_functional) do |spec|
  spec.pattern = 'spec/*_spec.rb'
  spec.rspec_opts = ['--options', "\"#{File.dirname(__FILE__)}/spec/spec.opts\""]
end

desc 'Run unit specs'
RSpec::Core::RakeTask.new(:spec_unit) do |spec|
  spec.pattern = 'spec/unit/*_spec.rb'
  spec.rspec_opts = ['--options', "\"#{File.dirname(__FILE__)}/spec/spec.opts\""]
end

desc 'Run all specs'
task :spec_ci do
  Rake::Task[:spec_unit].execute
  Rake::Task[:spec_functional].execute
end

desc 'Run all specs for all gemfiles'
task :spec do
  %w(7_1 7_0).each do |version|
    Bundler.with_original_env do
      puts "Running tests with ActiveSupport #{version.sub('_', '.')}"
      sh "env BUNDLE_GEMFILE=gemfiles/active_support_#{version} bundle install"
      sh "env BUNDLE_GEMFILE=gemfiles/active_support_#{version} bundle exec rake spec_unit spec_functional"
    end
  end
end
