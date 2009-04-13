require 'digest/md5'
require File.dirname(__FILE__) + '/persistence/properties'
require File.dirname(__FILE__) + '/persistence/magic_timestamps'
require File.dirname(__FILE__) + '/persistence/callbacks'
require File.dirname(__FILE__) + '/persistence/json'
require File.dirname(__FILE__) + '/persistence/dirty_attributes'
require File.dirname(__FILE__) + '/persistence/custom_view'
require File.dirname(__FILE__) + '/persistence/view_query'
require File.dirname(__FILE__) + '/persistence/persister'

module CouchPotato
  module Persistence
    
    class ValidationsFailedError < ::Exception; end
    class UnsavedDocumentError < ::Exception; end
    
    def self.included(base)
      base.send :extend, ClassMethods
      base.send :include, Properties, Callbacks, Validatable, Json, DirtyAttributes, CustomView
      base.send :include, MagicTimestamps
      base.class_eval do
        attr_accessor :_id, :_rev, :_attachments, :_deleted
        alias_method :id, :_id
      end
    end
    
    def initialize(attributes = {})
      attributes.each do |name, value|
        self.send("#{name}=", value)
      end if attributes
    end
    
    def attributes=(hash)
      hash.each do |attribute, value|
        self.send "#{attribute}=", value
      end
    end
    
    def update_attributes(hash)
      self.attributes = hash
      save
    end
    
    def attributes
      self.class.properties.inject({}) do |res, property|
        property.serialize(res, self)
        res
      end
    end
    
    def save!
      save || raise(ValidationsFailedError.new(self.errors.full_messages))
    end
    
    def save
      persister.save_document self
    end
    
    def destroy
      persister.destroy_document self
    end

    def reload
      raise(UnsavedDocumentError.new) unless _id
      json = self.class.db.get _id
      self.class.properties.each do |property|
        property.build self, json
      end
    end
    
    def new?
      _rev.nil?
    end
    
    def to_param
      _id
    end
    
    def ==(other)
      other.class == self.class && self.to_json == other.to_json
    end
    
    def persister
      @__persister ||= Persister.new(db)
    end
    
    def persister=(_persister)
      @__persister ||= _persister
    end
    
    private
    
    def db(name = nil)
      self.class.db name
    end
    
    module ClassMethods
      
      def create!(attributes = {})
        instance = self.new attributes
        instance.save!
        instance
      end
      
      def create(attributes = {})
        instance = self.new attributes
        instance.save
        instance
      end
      
      def get(id)
        begin
          self.json_create db.get(id)
        rescue(RestClient::ResourceNotFound)
          nil
        end
      end
      
      def db(name = nil)
        @__database ||= ::CouchPotato::Persistence.Db(name)
      end
      
      def db=(database)
        @__database = database
      end
      
    end
    
    def self.Db(database_name = nil)
      @@__database ||= CouchRest.database(full_url_to_database(database_name))
    end
    
    def self.Server(database_name = nil)
      @@_server ||= Db(database_name).server
    end
    
    def self.full_url_to_database(database_name)
      database_name ||= CouchPotato::Config.database_name || raise('No Database configured. Set CouchPotato::Config.database_name')
      url = database_name
      if url !~ /^http:\/\//
        url = "http://localhost:5984/#{database_name}"
      end
      url
    end
  end    
end