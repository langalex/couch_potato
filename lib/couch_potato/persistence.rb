require 'digest/md5'
require File.dirname(__FILE__) + '/database'
require File.dirname(__FILE__) + '/persistence/properties'
require File.dirname(__FILE__) + '/persistence/magic_timestamps'
require File.dirname(__FILE__) + '/persistence/callbacks'
require File.dirname(__FILE__) + '/persistence/json'
require File.dirname(__FILE__) + '/persistence/dirty_attributes'
require File.dirname(__FILE__) + '/view/custom_views'
require File.dirname(__FILE__) + '/view/view_query'


module CouchPotato
  module Persistence
    
    def self.included(base)
      base.send :include, Properties, Callbacks, Validatable, Json, DirtyAttributes, CouchPotato::View::CustomViews
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
    
    def attributes
      self.class.properties.inject({}) do |res, property|
        property.serialize(res, self)
        res
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
    
  end    
end