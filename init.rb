require File.dirname(__FILE__) + '/lib/couch_potatoe'

CouchPotatoe::Config.database_name = YAML::load(File.read(RAILS_ROOT + '/config/couchdb.yml'))[RAILS_ENV]