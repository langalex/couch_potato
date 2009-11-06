# this is for rails only

require File.expand_path(File.dirname(__FILE__) + '/../lib/couch_potato')

CouchPotato::Config.database_name = YAML::load(File.read(Rails.root.to_s + '/config/couchdb.yml'))[RAILS_ENV]

RAILS_DEFAULT_LOGGER.info "** couch_potato: initialized from #{__FILE__}"
