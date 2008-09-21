require 'couchrest'
require 'validatable'
require File.dirname(__FILE__) + '/persistence/class_methods'
require File.dirname(__FILE__) + '/persistence/collection'

module CouchPotatoe
  module Persistence
    
    class ValidationsFailedError < ::Exception; end
    class UnsavedRecordError < ::Exception; end
    
    def self.included(base)
      base.send :extend, ClassMethods
      base.send :include, Validatable
      base.class_eval do
        attr_accessor :_id, :_rev, :_attachments, :created_at, :updated_at
        
        alias_method :id, :_id
        
        def self.properties
          @@properties ||= {}
          @@properties[self.name] ||= []
        end
        
        def self.callbacks
          @@callbacks ||= {}
          @@callbacks[self.name] ||= {:before_validation_on_create => [], :before_create => [], 
            :after_create => [], :before_validation_on_update => [], :before_update => [],
            :after_update => []}
        end
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
    
    def to_json(*args)
      {
        'json_class' => self.class.name,
        'data' => (self.class.properties + [:created_at, :updated_at]).inject({}) do |props, name|
          props[name] = self.send(name) if self.send(name)
          props
        end
      }.to_json(*args)
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
      record = self.class.db(@database_name).save(self)
      self._id = record['id']
      self._rev = record['rev']
      run_callbacks :after_create
      true
    end
    
    def update_record
      run_callbacks(:before_validation_on_update)
      return unless valid?
      run_callbacks :before_update
      self.updated_at = Time.now
      self.class.db(@database_name).save(self.to_json)
      run_callbacks :after_update
      true
    end
    
    def run_callbacks(name)
      self.class.callbacks[name].each do |callback|
        self.send callback
      end
    end
    
    def self.Db(database_name = nil)
      database_name ||= CouchPotatoe::Config.database_name || raise('No Databaseconfigured. See CouchPotatoe::Config')
      full_url_to_database = database_name
      if full_url_to_database !~ /^http:\/\//
        full_url_to_database = "http://localhost:5984/#{database_name}"
      end
      CouchRest.database!(full_url_to_database)
    end
  end    
end