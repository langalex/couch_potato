require 'spec/rake/spectask'
require 'rake/gempackagetask'

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


spec = Gem::Specification.new do |s|
    s.name      =   "couch_potato"
    s.version   =   "0.1"
    s.author    =   "Alexander Lang"
    s.email     =   "alex@upstream-berlin.com"
    s.homepage  = 'http://github.com/langalex/couch_potato'
    s.summary   =   "a couchdb persistence layer in ruby"
    s.files     =   ['init.rb', 'Readme.textile', 'MIT-LICENSE.txt', 'CREDITS'] + Dir["{lib,spec}/**/*"]
    s.require_paths  <<  "lib"
    s.add_dependency 'json'
    s.add_dependency 'validatable'
    s.add_dependency 'activesupport'
    s.add_dependency 'jchris-couchrest', '>=0.9.12'
end

::Rake::GemPackageTask.new(spec) { |p| p.gem_spec = spec }

desc "Update Github Gemspec"
task :gemspec do
  skip_fields = %w(new_platform original_platform)
  integer_fields = %w(specification_version)

  result = "Gem::Specification.new do |s|\n"
  spec.instance_variables.each do |ivar|
    value = spec.instance_variable_get(ivar)
    name  = ivar.split("@").last
    next if skip_fields.include?(name) || value.nil? || value == "" || (value.respond_to?(:empty?) && value.empty?)
    if name == "dependencies"
      value.each do |d|
        dep, *ver = d.to_s.split(" ")
        result <<  "  s.add_dependency #{dep.inspect}, [#{ /\(([^\,]*)/ . match(ver.join(" "))[1].inspect}]\n"
      end
    else        
      case value
      when Array
        value =  name != "files" ? value.inspect : value.inspect.split(",").join(",\n")
      when Fixnum
        # leave as-is
      when String
        value = value.to_i if integer_fields.include?(name)
        value = value.inspect
      else
        value = value.to_s.inspect
      end
      result << "  s.#{name} = #{value}\n"
    end
  end
  result << "end"
  File.open(File.join(File.dirname(__FILE__), "#{spec.name}.gemspec"), "w"){|f| f << result}
end