require 'couchrest'
require 'json'

require 'ostruct'

JSON.create_id = 'ruby_class'
CouchRest.decode_json_objects = true
CouchRest::Connection::DEFAULT_HEADERS.merge!('Prefer' => 'return=minimal')

module CouchPotato
  Config = Struct.new(:database_host, :database_name, :digest_view_names,
    :split_design_documents_per_view, :default_language, :additional_databases).new
  Config.split_design_documents_per_view = false
  Config.digest_view_names = false
  Config.default_language = :javascript
  Config.database_host = 'http://127.0.0.1:5984'
  Config.additional_databases = {}

  class NotFound < StandardError; end
  class Conflict < StandardError; end

  # returns all the classes that include the CouchPotato::Persistence module
  def self.models
    @models ||= []
    @models
  end

  # Returns a database instance which you can then use to create objects and query views. You have to set the CouchPotato::Config.database_name before this works.
  def self.database
    Thread.current[:__couch_potato_database] ||= Database.new(couchrest_database)
  end

  # Returns the underlying CouchRest database object if you want low level access to your CouchDB. You have to set the CouchPotato::Config.database_name before this works.
  def self.couchrest_database
    Thread.current[:__couchrest_database] ||= CouchRest.database(full_url_to_database(CouchPotato::Config.database_name, CouchPotato::Config.database_host))
  end

  # Returns a specific database instance
  def self.use(database_name)
    resolved_database_name = Config.additional_databases[database_name] || database_name
    Thread.current[:__couch_potato_databases] ||= {}
    Thread.current[:__couch_potato_databases][resolved_database_name] = Database.new(couchrest_database_for_name!(resolved_database_name)) unless Thread.current[:__couch_potato_databases][resolved_database_name]
    Thread.current[:__couch_potato_databases][resolved_database_name]
  end

  # Executes a block of code and yields a datbase with the given name.
  #
  # example:
  #  CouchPotato.with_database('couch_customer') do |couch|
  #    couch.save @customer
  #  end
  #
  def self.with_database(database_name)
    yield use(database_name)
  end

  # Returns a CouchRest-Database for directly accessing that functionality.
  def self.couchrest_database_for_name(database_name)
    CouchRest.database(full_url_to_database(database_name, CouchPotato::Config.database_host))
  end

  # Creates a CouchRest-Database for directly accessing that functionality.
  def self.couchrest_database_for_name!(database_name)
    CouchRest.database!(full_url_to_database(database_name))
  end

  def self.full_url_to_database(database_name = CouchPotato::Config.database_name, database_host = CouchPotato::Config.database_host)
    raise('No Database configured. Set CouchPotato::Config.database_name') unless database_name
    if database_name.match(%r{https?://})
      database_name
    else
      "#{database_host}/#{database_name}"
    end
  end
end

$LOAD_PATH << File.dirname(__FILE__)

require 'couch_potato/validation'
require 'couch_potato/persistence'
require 'couch_potato/railtie' if defined?(Rails)
