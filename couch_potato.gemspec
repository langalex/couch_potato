# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{couch_potato}
  s.version = "0.1.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Alexander Lang"]
  s.date = %q{2009-04-27}
  s.description = %q{Ruby persistence layer for CouchDB}
  s.email = %q{alex@upstream-berlin.com}
  s.extra_rdoc_files = ["README.md", "README.textile"]
  s.files = ["MIT-LICENSE.txt", "README.md", "README.textile", "VERSION.yml", "lib/core_ext", "lib/core_ext/date.rb", "lib/core_ext/object.rb", "lib/core_ext/string.rb", "lib/core_ext/time.rb", "lib/couch_potato", "lib/couch_potato/database.rb", "lib/couch_potato/persistence", "lib/couch_potato/persistence/belongs_to_property.rb", "lib/couch_potato/persistence/callbacks.rb", "lib/couch_potato/persistence/dirty_attributes.rb", "lib/couch_potato/persistence/inline_collection.rb", "lib/couch_potato/persistence/json.rb", "lib/couch_potato/persistence/magic_timestamps.rb", "lib/couch_potato/persistence/properties.rb", "lib/couch_potato/persistence/simple_property.rb", "lib/couch_potato/persistence.rb", "lib/couch_potato/view", "lib/couch_potato/view/base_view_spec.rb", "lib/couch_potato/view/custom_view_spec.rb", "lib/couch_potato/view/custom_views.rb", "lib/couch_potato/view/model_view_spec.rb", "lib/couch_potato/view/properties_view_spec.rb", "lib/couch_potato/view/raw_view_spec.rb", "lib/couch_potato/view/view_query.rb", "lib/couch_potato.rb", "spec/callbacks_spec.rb", "spec/create_spec.rb", "spec/custom_view_spec.rb", "spec/destroy_spec.rb", "spec/property_spec.rb", "spec/spec.opts", "spec/spec_helper.rb", "spec/unit", "spec/unit/attributes_spec.rb", "spec/unit/create_spec.rb", "spec/unit/dirty_attributes_spec.rb", "spec/unit/string_spec.rb", "spec/unit/view_query_spec.rb", "spec/update_spec.rb", "rails/init.rb", "init.rb"]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/langalex/couch_potato}
  s.rdoc_options = ["--inline-source", "--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{Ruby persistence layer for CouchDB}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<json>, [">= 0"])
      s.add_runtime_dependency(%q<validatable>, [">= 0"])
      s.add_runtime_dependency(%q<jchris-couchrest>, ["= 0.9.12"])
    else
      s.add_dependency(%q<json>, [">= 0"])
      s.add_dependency(%q<validatable>, [">= 0"])
      s.add_dependency(%q<jchris-couchrest>, ["= 0.9.12"])
    end
  else
    s.add_dependency(%q<json>, [">= 0"])
    s.add_dependency(%q<validatable>, [">= 0"])
    s.add_dependency(%q<jchris-couchrest>, ["= 0.9.12"])
  end
end
