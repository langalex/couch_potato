require 'couchrest'
require 'json'
require 'json/add/core'

require 'ostruct'

JSON.create_id = 'ruby_class'

module CouchPotato
  Config = Struct.new(:database_name, :split_design_documents_per_view, :default_language).new
  Config.split_design_documents_per_view = false
  Config.default_language = :javascript

  class NotFound < StandardError; end

  # returns all the classes that implement the CouchPotato::Persistence module
  def self.models
    @models ||= []
    @models
  end

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
    raise('No Database configured. Set CouchPotato::Config.database_name') unless CouchPotato::Config.database_name
    if CouchPotato::Config.database_name.match(%r{https?://})
      CouchPotato::Config.database_name
    else
      "http://127.0.0.1:5984/#{CouchPotato::Config.database_name}"
    end
  end
end

$LOAD_PATH << File.dirname(__FILE__)

require 'core_ext/object'
require 'core_ext/time'
require 'core_ext/date'
require 'core_ext/string'
require 'core_ext/symbol'
require 'couch_potato/validation'
require 'couch_potato/persistence'
require 'couch_potato/railtie' if defined?(Rails)
