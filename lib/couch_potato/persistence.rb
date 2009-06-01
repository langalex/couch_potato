require 'digest/md5'
require File.dirname(__FILE__) + '/database'
require File.dirname(__FILE__) + '/persistence/properties'
require File.dirname(__FILE__) + '/persistence/magic_timestamps'
require File.dirname(__FILE__) + '/persistence/callbacks'
require File.dirname(__FILE__) + '/persistence/json'
require File.dirname(__FILE__) + '/persistence/dirty_attributes'
require File.dirname(__FILE__) + '/persistence/validation'
require File.dirname(__FILE__) + '/view/custom_views'
require File.dirname(__FILE__) + '/view/view_query'


module CouchPotato
  module Persistence
    
    def self.included(base)
      base.send :include, Properties, Callbacks, Validation, Json, CouchPotato::View::CustomViews
      base.send :include, DirtyAttributes
      base.send :include, MagicTimestamps
      base.class_eval do
        attr_accessor :_id, :_rev, :_attachments, :_deleted
        alias_method :id, :_id
      end
    end

    # initialize a new instance of the model optionally passing it a hash of attributes.
    # the attributes have to be declared using the #property method
    # 
    # example: 
    #   class Book
    #     include CouchPotato::Persistence
    #     property :title
    #   end
    #   book = Book.new :title => 'Time to Relax'
    #   book.title # => 'Time to Relax'
    def initialize(attributes = {})
      attributes.each do |name, value|
        self.send("#{name}=", value)
      end if attributes
    end
    
    # assign multiple attributes at once.
    # the attributes have to be declared using the #property method
    #
    # example:
    #   class Book
    #     include CouchPotato::Persistence
    #     property :title
    #     property :year
    #   end
    #   book = Book.new
    #   book.attributes = {:title => 'Time to Relax', :year => 2009}
    #   book.title # => 'Time to Relax'
    #   book.year # => 2009
    def attributes=(hash)
      hash.each do |attribute, value|
        self.send "#{attribute}=", value
      end
    end
    
    # returns all of a model's attributes that have been defined using the #property method as a Hash
    #
    # example:
    #   class Book
    #     include CouchPotato::Persistence
    #     property :title
    #     property :year
    #   end
    #   book = Book.new :year => 2009
    #   book.attributes # => {:title => nil, :year => 2009}
    def attributes
      self.class.properties.inject({}) do |res, property|
        property.serialize(res, self)
        res
      end
    end
    
    # returns true if a  model hasn't been saved yet, false otherwise
    def new?
      _rev.nil?
    end
    
    # returns the document id
    # this is used by rails to construct URLs
    # can be overridden to for example use slugs for URLs instead if ids
    def to_param
      _id
    end
    
    def ==(other) #:nodoc:
      other.class == self.class && self.to_json == other.to_json
    end
    
  end    
end