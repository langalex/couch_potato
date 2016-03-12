require File.dirname(__FILE__) + '/simple_property'
require File.dirname(__FILE__) + '/deep_tracked_property'

module CouchPotato
  module Persistence
    module Properties
      class PropertyList
        include Enumerable

        attr_accessor :list

        def initialize(clazz)
          @clazz = clazz
          @list = []
          @hash = {}
        end

        def each(&block)
          (list + inherited_properties).each(&block)
        end

        def <<(property)
          @hash[property.name] = property
          @list << property
        end

        def find_property(name)
          @hash[name]
        end

        # XXX
        def inspect
          list.map(&:name).inspect
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

      def self.included(base) #:nodoc:
        base.extend ClassMethods
        base.class_eval do
          def self.properties
            @properties ||= {}
            @properties[name] ||= PropertyList.new(self)
            @properties[name]
          end
        end
      end

      def type_caster #:nodoc:
        @type_caster ||= TypeCaster.new
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

        # Declare a property on a model class. Properties are not typed by default.
        # You can store anything in a property that can be serialized into JSON.
        # If you want a property to be of a custom class you have to define it using the :type option.
        #
        # example:
        #  class Book
        #    property :title
        #    property :year
        #    property :publisher, type: Publisher
        #    property :published_at, default: -> { Date.current }
        #    property :next_year, default: ->(book) { book.year + 1 }
        #  end
        def property(name, options = {})
          # ActiveModel::AttributeMethods.generated_attribute_methods
          active_support_module = send(:generated_attribute_methods)

          # Mimic ActiveModel::AttributeMethods.undefine_attribute_methods, but only for this
          # property's accessor method
          active_support_module.module_eval do
            undef_method(name) if instance_methods.include?(name)
          end
          cache = send(:attribute_method_matchers_cache)
          cache.delete(name)

          define_attribute_method name
          properties << SimpleProperty.new(self, name, options)

          # Remove the default ActiveModel::AttributeMethods accessor
          if active_support_module.instance_methods.include?(name)
            active_support_module.send(:remove_method, name)
          end
        end
      end
    end
  end
end
