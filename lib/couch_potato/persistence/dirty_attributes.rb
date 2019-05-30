require 'bigdecimal'
module CouchPotato
  module Persistence
    module DirtyAttributes

      def self.included(base) #:nodoc:
        base.send :include, ActiveModel::Dirty
        base.class_eval do
          after_save :clear_changes_information
        end
      end

      private

      def clone_attribute(value)
        if [Integer, Symbol, TrueClass, FalseClass, NilClass, Float, BigDecimal].find{|klass| value.is_a?(klass)}
          value
        elsif [Hash, Array].include?(value.class)
          # Deep clone
          Marshal::load(Marshal::dump(value))
        else
          value.clone
        end
      end
    end
  end
end
