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
        #    property :publisher, :type => Publisher
        #  end
        def property(name, options = {})
          undefine_attribute_methods
          define_attribute_methods property_names + [name]
          properties << SimpleProperty.new(self, name, options)
          remove_attribute_accessors_from_activesupport_module
        end

        def remove_attribute_accessors_from_activesupport_module
          active_support_module = ancestors[1..-1].find{|m| m.name.nil? && (property_names - m.instance_methods).empty?}
          if active_support_module
            property_names.each do |name|
              active_support_module.send :remove_method, name if active_support_module.instance_methods.include?(name)
            end
          end
        end
      end
    end
  end
end
