require File.dirname(__FILE__) + '/simple_property'
require File.dirname(__FILE__) + '/belongs_to_property'
require File.dirname(__FILE__) + '/inline_has_many_property'
require File.dirname(__FILE__) + '/external_has_many_property'

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
          properties << (options[:class] || SimpleProperty).new(self, name)
        end

        def belongs_to(name)
          property name, :class => BelongsToProperty
        end

        def has_many(name, options = {})
          if(options[:stored] == :inline)
            property name, :class => InlineHasManyProperty
          else
            property name, :class => ExternalHasManyProperty
          end
        end
      end
    end
  end
end