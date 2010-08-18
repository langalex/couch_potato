require 'active_support/concern'
require 'active_model/callbacks'

module CouchPotato
  module Persistence
    module Callbacks
      def self.included(base) #:nodoc:
        base.extend ActiveModel::Callbacks

        base.class_eval do
          attr_accessor :skip_callbacks

          define_model_callbacks :create, :save, :update, :destroy
          define_model_callbacks *[:save, :create, :update].map {|c| :"validation_on_#{c}"}
          define_model_callbacks :validation unless Config.validation_framework == :active_model
        end
      end

      # Runs all callbacks on a model with the given name, e.g. :after_create.
      # 
      # This method is called by the CouchPotato::Database object when saving/destroying an object 
      def run_callbacks(name, &block)
        return if skip_callbacks

        send(:"_run_#{name}_callbacks", &block)
      end
    end
  end
end
