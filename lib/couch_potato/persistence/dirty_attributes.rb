require 'bigdecimal'
module CouchPotato
  module Persistence
    module DirtyAttributes
      
      def self.included(base) #:nodoc:
        base.class_eval do
          after_save :reset_dirty_attributes
          
          def initialize(attributes = {})
            super
            assign_attribute_copies_for_dirty_tracking
          end
        end
      end
      
      # returns true if a model has dirty attributes, i.e. their value has changed since the last save
      def dirty? 
        new? || @forced_dirty || self.class.properties.inject(false) do |res, property|
          res || property.dirty?(self)
        end
      end
      
      # marks a model as dirty
      def is_dirty
        @forced_dirty = true
      end
      
      private
      
      def assign_attribute_copies_for_dirty_tracking
        attributes.each do |name, value|
          self.instance_variable_set("@#{name}_was", clone_attribute(value))
        end if attributes
      end
      
      def reset_dirty_attributes
        @forced_dirty = nil
        self.class.properties.each do |property|
          instance_variable_set("@#{property.name}_was", clone_attribute(send(property.name)))
        end
      end
      
      def clone_attribute(value)
        if [Fixnum, Symbol, TrueClass, FalseClass, NilClass, Float, BigDecimal].include?(value.class)
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
