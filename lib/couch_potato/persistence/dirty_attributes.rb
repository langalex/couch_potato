module CouchPotato
  module Persistence
    module DirtyAttributes
      
      def self.included(base)
        base.class_eval do
          after_save :reset_dirty_attributes
        end
      end
      
      # returns true if a model has dirty attributes, i.e. their value has changed since the last save
      def dirty? 
        new? || self.class.properties.inject(false) do |res, property|
          res || property.dirty?(self)
        end
      end
      
      private
      
      def reset_dirty_attributes
        self.class.properties.each do |property|
          instance_variable_set("@#{property.name}_was", clone_attribute(send(property.name)))
        end
      end
      
      def clone_attribute(value)
        if [Fixnum, Symbol, TrueClass, FalseClass, NilClass, Float].include?(value.class)
          value
        elsif [Hash, Array].include?(value.class)
          #Deep clone
          Marshal::load(Marshal::dump(value))
        else
          value.clone
        end
      end
    end
  end
end
