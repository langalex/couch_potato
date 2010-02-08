# this is for rails only

require File.expand_path(File.dirname(__FILE__) + '/../lib/couch_potato')

CouchPotato::Config.database_name = YAML::load(File.read(Rails.root.to_s + '/config/couchdb.yml'))[Rails.env]

Rails.logger.info "** couch_potato: initialized from #{__FILE__}"
