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
    end
  end
end
