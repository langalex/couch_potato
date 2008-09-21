require 'couchrest'
require 'validatable'
require File.dirname(__FILE__) + '/persistence/inline_collection'
require File.dirname(__FILE__) + '/persistence/lazy_collection'
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
    
    def reload
      raise(UnsavedRecordError.new) unless _id
      reloaded = self.class.find _id
      self.class.properties.each do |name|
        self.send "#{name}=", reloaded.send(name)
      end
    end
    
    def new_record?
      _rev.nil?
    end
    
    def to_param
      _id
    end
    
    def [](name)
      self.send name
    end
    
    def ==(other)
      other.class == self.class && self.class.properties.map{|name| self.send(name)} == self.class.properties.map{|name| other.send(name)}
    end
    
    private
    
    def create_record
      run_callbacks :before_validation_on_create
      return unless valid?
      run_callbacks :before_create
      self.created_at = Time.now
      self.updated_at = Time.now
      record = self.class.db.save(self)
      self._id = record['id']
      self._rev = record['rev']
      save_dependent_objects
      run_callbacks :after_create
      true
    end
    
    def update_record
      run_callbacks(:before_validation_on_update)
      return unless valid?
      run_callbacks :before_update
      self.updated_at = Time.now
      self.class.db.save(self.to_json)
      save_dependent_objects
      run_callbacks :after_update
      true
    end
    
    def save_dependent_objects
      self.class.properties.each do |name|
        property = self.send name
        property.owner_id = self._id if property.respond_to?(:owner_id=)
        property.save if property.respond_to?(:save)
      end
    end
    
    module ClassMethods
      
      def create!(attributes)
        record = self.new attributes
        record.save!
        record
      end
      
      def find(id)
        db.get(id)
      end
      
      def db(name = nil)
        ::CouchPotatoe::Persistence.Db(name)
      end
    end
    
    def self.Db(database_name = nil)
      database_name ||= CouchPotatoe::Config.database_name || raise('No Database configured. Set CouchPotatoe::Config.database')
      full_url_to_database = database_name
      if full_url_to_database !~ /^http:\/\//
        full_url_to_database = "http://localhost:5984/#{database_name}"
      end
      CouchRest.database!(full_url_to_database)
    end
  end    
end