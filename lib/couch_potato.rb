require 'couchrest'
require 'json'
require 'json/add/core'

require 'ostruct'

JSON.create_id = 'ruby_class'
CouchRest.decode_json_objects = true

module CouchPotato
  Config = Struct.new(:database_host, :database_name, :split_design_documents_per_view, :default_language).new
  Config.split_design_documents_per_view = false
  Config.default_language = :javascript
  Config.database_host = "http://127.0.0.1:5984"

  class NotFound < StandardError; end
  class Conflict < StandardError; end

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
    @@__couchrest_database ||= CouchRest.database(full_url_to_database(CouchPotato::Config.database_name, CouchPotato::Config.database_host))
  end

  # Executes a block of code and yields a datbase with the given name.
  #
  # example:
  #  CouchPotato.with_database('couch_customer') do |couch|
  #    couch.save @customer
  #  end
  #
  def self.with_database(database_name)
    @@__databases ||= {}
    @@__databases["#{database_name}"] = Database.new(couchrest_database_for_name(database_name)) unless @@__databases["#{database_name}"]
    yield(@@__databases["#{database_name}"])
  end

  # Creates a CouchRest-Database for directly accessing that functionality.
  def self.couchrest_database_for_name(database_name)
    CouchRest.database(full_url_to_database(database_name, CouchPotato::Config.database_host))
  end

  private

  def self.full_url_to_database(database_name=CouchPotato::Config.database_name, database_host = CouchPotato::Config.database_host)
    raise('No Database configured. Set CouchPotato::Config.database_name') unless database_name
    if database_name.match(%r{https?://})
      database_name
    else
      "#{database_host}/#{database_name}"
    end
  end
end

$LOAD_PATH << File.dirname(__FILE__)

require 'core_ext/time'
require 'core_ext/date'
require 'couch_potato/validation'
require 'couch_potato/persistence'
require 'couch_potato/railtie' if defined?(Rails)
