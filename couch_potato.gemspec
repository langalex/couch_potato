# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{couch_potato}
  s.version = "0.1.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Alexander Lang"]
  s.date = %q{2009-02-15}
  s.description = %q{Ruby persistence layer for CouchDB}
  s.email = %q{alex@upstream-berlin.com}
  s.files = ["MIT-LICENSE.txt", "README.textile", "VERSION.yml", "lib/core_ext", "lib/core_ext/object.rb", "lib/core_ext/time.rb", "lib/couch_potato", "lib/couch_potato/active_record", "lib/couch_potato/active_record/compatibility.rb", "lib/couch_potato/ordering.rb", "lib/couch_potato/persistence", "lib/couch_potato/persistence/belongs_to_property.rb", "lib/couch_potato/persistence/bulk_save_queue.rb", "lib/couch_potato/persistence/callbacks.rb", "lib/couch_potato/persistence/collection.rb", "lib/couch_potato/persistence/custom_view.rb", "lib/couch_potato/persistence/dirty_attributes.rb", "lib/couch_potato/persistence/external_collection.rb", "lib/couch_potato/persistence/external_has_many_property.rb", "lib/couch_potato/persistence/find.rb", "lib/couch_potato/persistence/finder.rb", "lib/couch_potato/persistence/inline_collection.rb", "lib/couch_potato/persistence/inline_has_many_property.rb", "lib/couch_potato/persistence/json.rb", "lib/couch_potato/persistence/properties.rb", "lib/couch_potato/persistence/simple_property.rb", "lib/couch_potato/persistence/view_query.rb", "lib/couch_potato/persistence.rb", "lib/couch_potato/versioning.rb", "lib/couch_potato.rb", "spec/attributes_spec.rb", "spec/belongs_to_spec.rb", "spec/callbacks_spec.rb", "spec/create_spec.rb", "spec/custom_view_spec.rb", "spec/destroy_spec.rb", "spec/dirty_attributes_spec.rb", "spec/find_spec.rb", "spec/finder_spec.rb", "spec/has_many_spec.rb", "spec/inline_collection_spec.rb", "spec/ordering_spec.rb", "spec/property_spec.rb", "spec/reload_spec.rb", "spec/spec.opts", "spec/spec_helper.rb", "spec/unit", "spec/unit/external_collection_spec.rb", "spec/unit/finder_spec.rb", "spec/unit/view_query_spec.rb", "spec/update_spec.rb", "spec/versioning_spec.rb"]
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
    else
    end
  else
  end
end
