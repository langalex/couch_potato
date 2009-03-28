require File.dirname(__FILE__) + '/simple_property'
require File.dirname(__FILE__) + '/belongs_to_property'

module CouchPotato
  module Persistence
    module Properties
      def self.included(base)
        base.extend ClassMethods
        base.class_eval do
          def self.properties
            @@properties ||= {}
            @@properties[self.name] ||= []
          end
        end
      end
      
      module ClassMethods
        def property_names
          properties.map(&:name)
        end
        
        def property(name, options = {})
          clazz = options.delete(:class)
          properties << (clazz || SimpleProperty).new(self, name, options)
        end

        def belongs_to(name)
          property name, :class => BelongsToProperty
        end

      end
    end
  end
end