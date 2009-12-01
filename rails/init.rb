# this is for rails only

require File.expand_path(File.dirname(__FILE__) + '/../lib/couch_potato')
require File.expand_path(File.dirname(__FILE__) + '/reload_classes')

CouchPotato::Config.database_name = YAML::load(File.read(Rails.root.to_s + '/config/couchdb.yml'))[RAILS_ENV]

RAILS_DEFAULT_LOGGER.info "** couch_potato: initialized from #{__FILE__}"
