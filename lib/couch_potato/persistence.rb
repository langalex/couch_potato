require 'digest/md5'
require File.dirname(__FILE__) + '/persistence/properties'
require File.dirname(__FILE__) + '/persistence/callbacks'
require File.dirname(__FILE__) + '/persistence/json'
require File.dirname(__FILE__) + '/persistence/dirty_attributes'
require File.dirname(__FILE__) + '/persistence/custom_view'
require File.dirname(__FILE__) + '/persistence/view_query'

module CouchPotato
  module Persistence
    
    class ValidationsFailedError < ::Exception; end
    class UnsavedRecordError < ::Exception; end
    
    def self.included(base)
      base.send :extend, ClassMethods
      base.send :include, Callbacks, Properties, Validatable, Json, DirtyAttributes, CustomView
      base.class_eval do
        attr_accessor :_id, :_rev, :_attachments, :_deleted, :created_at, :updated_at
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
      if new_document?
        create_document 
      else
        update_document
      end
    end
    
    def destroy
      run_callbacks(:before_destroy)
      self._deleted = true
      db.delete_doc self.to_hash
      run_callbacks(:after_destroy)
      self._id = nil
      self._rev = nil
    end

    def reload
      raise(UnsavedRecordError.new) unless _id
      json = self.class.db.get _id
      self.class.properties.each do |property|
        property.build self, json
      end
    end
    
    def new_document?
      _id.nil?
    end
    
    def to_param
      _id
    end
    
    def [](name)
      self.send name
    end
    
    def ==(other)
      other.class == self.class && self.to_json == other.to_json
    end
    
    private
    
    def create_document
      run_callbacks :before_validation_on_save
      run_callbacks :before_validation_on_create
      return unless valid?
      run_callbacks :before_save
      run_callbacks :before_create
      self.created_at = Time.now
      self.updated_at = Time.now
      res = db.save_doc self.to_hash
      self._rev = res['rev']
      self._id = res['id']
      run_callbacks :after_save
      run_callbacks :after_create
      true
    end
    
    def generate_uuid
      self.class.server.next_uuid rescue Digest::MD5.hexdigest(rand(1000000000000).to_s) # only works with couchdb 0.9
    end
    
    def update_document
      run_callbacks(:before_validation_on_save)
      run_callbacks(:before_validation_on_update)
      return unless valid?
      run_callbacks :before_save
      run_callbacks :before_update
      self.updated_at = Time.now
      res = db.save_doc self.to_hash
      self._rev = res['rev']
      run_callbacks :after_save
      run_callbacks :after_update
      true
    end
    
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
        ::CouchPotato::Persistence.Db(name)
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