Gem::Specification.new do |s|
  s.add_dependency "json", [">= 0"]
  s.add_dependency "validatable", [">= 0"]
  s.add_dependency "activesupport", [">= 0"]
  s.add_dependency "jchris-couchrest", [">= 0.9.12"]
  s.require_paths = ["lib", "lib"]
  s.date = "Mon Oct 27 00:00:00 +0100 2008"
  s.authors = ["Alexander Lang"]
  s.name = "couch_potato"
  s.required_rubygems_version = ">= 0"
  s.files = ["init.rb",
 "Readme.textile",
 "MIT-LICENSE.txt",
 "CREDITS",
 "lib/core_ext",
 "lib/core_ext/object.rb",
 "lib/core_ext/time.rb",
 "lib/couch_potato",
 "lib/couch_potato/active_record",
 "lib/couch_potato/active_record/compatibility.rb",
 "lib/couch_potato/ordering.rb",
 "lib/couch_potato/persistence",
 "lib/couch_potato/persistence/belongs_to_property.rb",
 "lib/couch_potato/persistence/bulk_save_queue.rb",
 "lib/couch_potato/persistence/callbacks.rb",
 "lib/couch_potato/persistence/collection.rb",
 "lib/couch_potato/persistence/external_collection.rb",
 "lib/couch_potato/persistence/external_has_many_property.rb",
 "lib/couch_potato/persistence/find.rb",
 "lib/couch_potato/persistence/finder.rb",
 "lib/couch_potato/persistence/inline_collection.rb",
 "lib/couch_potato/persistence/inline_has_many_property.rb",
 "lib/couch_potato/persistence/json.rb",
 "lib/couch_potato/persistence/properties.rb",
 "lib/couch_potato/persistence/simple_property.rb",
 "lib/couch_potato/persistence.rb",
 "lib/couch_potato/versioning.rb",
 "lib/couch_potato.rb",
 "spec/attributes_spec.rb",
 "spec/belongs_to_spec.rb",
 "spec/callbacks_spec.rb",
 "spec/create_spec.rb",
 "spec/destroy_spec.rb",
 "spec/find_spec.rb",
 "spec/finder_spec.rb",
 "spec/has_many_spec.rb",
 "spec/inline_collection_spec.rb",
 "spec/ordering_spec.rb",
 "spec/property_spec.rb",
 "spec/reload_spec.rb",
 "spec/spec.opts",
 "spec/spec_helper.rb",
 "spec/update_spec.rb",
 "spec/versioning_spec.rb"]
  s.has_rdoc = "false"
  s.specification_version = 2
  s.loaded = "false"
  s.email = "alex@upstream-berlin.com"
  s.required_ruby_version = ">= 0"
  s.bindir = "bin"
  s.rubygems_version = "1.2.0"
  s.homepage = "http://github.com/langalex/couch_potato"
  s.platform = "ruby"
  s.summary = "a couchdb persistence layer in ruby"
  s.version = "0.1"
end