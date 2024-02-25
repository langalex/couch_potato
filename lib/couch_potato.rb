# frozen_string_literal: true

require 'couchrest'
require 'json'

require 'ostruct'

JSON.create_id = 'ruby_class'
CouchRest.decode_json_objects = true

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

  def self.configure(config)
    if config.is_a?(String)
      Config.database_name = config
    else
      config = config.stringify_keys
      Config.database_name = config['database']
      Config.database_host = config['database_host'] if config['database_host']
      Config.additional_databases = config['additional_databases'].stringify_keys if config['additional_databases']
      Config.split_design_documents_per_view = config['split_design_documents_per_view'] if config['split_design_documents_per_view']
      Config.digest_view_names = config['digest_view_names'] if config['digest_view_names']
      Config.default_language = config['default_language'] if config['default_language']
    end
  end

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
    resolved_database_name = resolve_database_name(database_name)
    Thread.current[:__couch_potato_databases] ||= {}
    Thread.current[:__couch_potato_databases][resolved_database_name] ||= Database.new(couchrest_database_for_name(resolved_database_name), name: database_name)
  end

  # resolves a name to a database name/full url configured under additional databases
  def self.resolve_database_name(database_name)
    Config.additional_databases[database_name] || database_name
  end

  # Executes a block of code and yields a database with the given name.
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
    Thread.current[:__couchrest_databases] ||= {}
    Thread.current[:__couchrest_databases][database_name] ||= CouchRest.database(full_url_to_database(database_name, CouchPotato::Config.database_host))
  end

  # Creates a CouchRest-Database for directly accessing that functionality.
  def self.couchrest_database_for_name!(database_name)
    Thread.current[:__couchrest_databases] ||= {}
    Thread.current[:__couchrest_databases][database_name] ||= CouchRest.database!(full_url_to_database(database_name))
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

require 'core_ext/time'
require 'core_ext/date'
require 'couch_potato/validation'
require 'couch_potato/persistence'
require 'couch_potato/railtie' if defined?(Rails)
