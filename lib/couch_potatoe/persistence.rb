require 'couchrest'
require 'validatable'
require File.dirname(__FILE__) + '/persistence/inline_collection'
require File.dirname(__FILE__) + '/persistence/external_collection'
require File.dirname(__FILE__) + '/persistence/properties'
require File.dirname(__FILE__) + '/persistence/callbacks'
require File.dirname(__FILE__) + '/persistence/json'

module CouchPotatoe
  module Persistence
    
    class ValidationsFailedError < ::Exception; end
    class UnsavedRecordError < ::Exception; end
    
    def self.included(base)
      base.send :extend, ClassMethods
      base.send :include, Callbacks, Properties, Validatable, Json
      base.class_eval do
        attr_accessor :_id, :_rev, :_attachments, :created_at, :updated_at
        alias_method :id, :_id
      end
    end
    
    def initialize(attributes = {})
      attributes.each do |name, value|
        self.send("#{name}=", value)
      end if attributes
    end
    
    def save!
      save || raise(ValidationsFailedError.new(self.errors.full_messages))
    end
    
    def save
      if new_record?
        create_record 
      else
        update_record
      end
    end
    
    def destroy
      run_callbacks(:before_destroy)
      self.class.db.delete self
      run_callbacks(:after_destroy)
      self._id = nil
      self._rev = nil
    end
    
    def reload
      raise(UnsavedRecordError.new) unless _id
      reloaded = self.class.get _id
      self.class.properties.each do |property|
        json = {}
        property.serialize(json, reloaded)
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
      other.class == self.class && self.class.property_names.map{|name| self.send(name)} == self.class.property_names.map{|name| other.send(name)}
    end
    
    private
    
    def create_record
      run_callbacks :before_validation_on_save
      run_callbacks :before_validation_on_create
      return unless valid?
      run_callbacks :before_save
      run_callbacks :before_create
      self.created_at = Time.now
      self.updated_at = Time.now
      document = self.class.db.save(self)
      self._id = document['id']
      self._rev = document['rev']
      save_dependent_objects
      run_callbacks :after_save
      run_callbacks :after_create
      true
    end
    
    def update_record
      run_callbacks(:before_validation_on_save)
      run_callbacks(:before_validation_on_update)
      return unless valid?
      run_callbacks :before_save
      run_callbacks :before_update
      self.updated_at = Time.now
      res = self.class.db.save(self)
      save_dependent_objects
      self._rev = res['rev']
      run_callbacks :after_save
      run_callbacks :after_update
      true
    end
    
    def save_dependent_objects
      self.class.properties.each do |property|
        property.save(self)
      end
    end
    
    module ClassMethods
      
      def create!(attributes = {})
        instance = self.new attributes
        instance.save!
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
        ::CouchPotatoe::Persistence.Db(name)
      end
    end
    
    def self.Db(database_name = nil)
      database_name ||= CouchPotatoe::Config.database_name || raise('No Database configured. Set CouchPotatoe::Config.database_name')
      full_url_to_database = database_name
      if full_url_to_database !~ /^http:\/\//
        full_url_to_database = "http://localhost:5984/#{database_name}"
      end
      CouchRest.database!(full_url_to_database)
    end
  end    
end