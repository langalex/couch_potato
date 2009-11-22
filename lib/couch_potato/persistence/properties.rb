require File.dirname(__FILE__) + '/simple_property'

module CouchPotato
  module Persistence
    module Properties
      class PropertyList
        include Enumerable
        
        attr_accessor :list
        
        def initialize(clazz)
          @clazz = clazz
          @list = []
        end
        
        def each
          (list + inherited_properties).each {|property| yield property}
        end
        
        def <<(property)
          @list << property
        end
        
        def inherited_properties
          superclazz = @clazz.superclass
          properties = []
          while superclazz && superclazz.respond_to?(:properties)
            properties << superclazz.properties.list
            superclazz = superclazz.superclass
          end
          properties.flatten
        end
      end
      
      def self.included(base)
        base.extend ClassMethods
        base.class_eval do
          def self.properties
            @properties ||= {}
            @properties[name] ||= PropertyList.new(self)
          end
        end
      end
      
      module ClassMethods
        # returns all the property names of a model class that have been defined using the #property method
        #
        # example:
        #  class Book
        #    property :title
        #    property :year
        #  end
        #  Book.property_names # => [:title, :year]
        def property_names
          properties.map(&:name)
        end

        def json_create(json) #:nodoc:
          return if json.nil?
          instance = super
          instance.send(:assign_attribute_copies_for_dirty_tracking)
          instance
        end

        # Declare a property on a model class. properties are not typed by default. You can use any of the basic types by JSON (String, Integer, Fixnum, Array, Hash). If you want a property to be of a custom class you have to define it using the :class option.
        #
        # example:
        #  class Book
        #    property :title
        #    property :year
        #    property :publisher, :class => Publisher
        #  end
        def property(name, options = {})
          clazz = options.delete(:class)
          properties << (clazz || SimpleProperty).new(self, name, options)
        end

      end
    end
  end
end
