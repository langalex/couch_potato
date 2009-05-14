require 'couchrest'
require 'json'
require 'json/add/core'
require 'json/add/rails'

require 'ostruct'

require 'validatable'


module CouchPotato
  Config = OpenStruct.new
  
  # Returns a database instance which you can then use to create objects and query views. You have to set the CouchPotato::Config.database_name before this works.
  def self.database
    @@__database ||= Database.new(self.couchrest_database)
  end
  
  # Returns the underlying CouchRest database object if you want low level access to your CouchDB. You have to set the CouchPotato::Config.database_name before this works.
  def self.couchrest_database
    @@__couchrest_database ||= CouchRest.database(full_url_to_database)
  end
  
  private
  
  def self.full_url_to_database
    database_name = CouchPotato::Config.database_name || raise('No Database configured. Set CouchPotato::Config.database_name')
    url = database_name
    if url !~ /^http:\/\//
      url = "http://localhost:5984/#{database_name}"
    end
    url
  end
end

require File.dirname(__FILE__) + '/core_ext/object'
require File.dirname(__FILE__) + '/core_ext/time'
require File.dirname(__FILE__) + '/core_ext/date'
require File.dirname(__FILE__) + '/core_ext/string'
require File.dirname(__FILE__) + '/couch_potato/persistence'

