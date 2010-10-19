require 'bigdecimal'
module CouchPotato
  module Persistence
    module DirtyAttributes
      
      def self.included(base) #:nodoc:
        base.send :include, ActiveModel::Dirty
        base.class_eval do
          after_save :reset_dirty_attributes
        end
      end
      
      def initialize(attributes = {})
        super
        # assign_attribute_copies_for_dirty_tracking
      end
    
      # returns true if a model has dirty attributes, i.e. their value has changed since the last save
      def dirty? 
        changed? || @forced_dirty
      end
      
      # marks a model as dirty
      def is_dirty
        @forced_dirty = true
      end
      
      def method_missing(name, *args)
        if(name.to_s.include?('_will_change!'))
          self.class.define_attribute_methods self.class.property_names
          send(name, *args)
        else
          super
        end
      end
      
      private
      
      def reset_dirty_attributes
        @previously_changed = changes
        @changed_attributes.clear
        @forced_dirty = nil
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
