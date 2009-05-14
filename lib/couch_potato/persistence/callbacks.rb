module CouchPotato
  module Persistence
    module Callbacks
      
      class Callback #:nodoc:
        def initialize(model, name, database)
          @model, @name, @database = model, name, database
        end
        
        def run
          if @name.is_a?(Symbol)
            run_method_callback @name
          elsif @name.is_a?(Proc)
            run_lambda_callback @name
          else
            raise "Don't know how to handle callback of type #{name.class.name}"
          end
        end
        
        private
        
        def run_method_callback(name)
          if callback_method(name).arity == 0
            @model.send name
          elsif callback_method(name).arity == 1
            @model.send name, @database
          else
            raise "Don't know how to handle method callback with #{callback_method(name).arity} arguments"
          end
        end
        
        def callback_method(name)
          @model.method(name)
        end

        def run_lambda_callback(lambda)
          if lambda.arity == 1
            lambda.call @model
          elsif lambda.arity == 2
            lambda.call @model, @database
          else raise "Don't know how to handle lambda callback with #{lambda.arity} arguments"
          end
        end
        
      end
      
      def self.included(base)
        base.extend ClassMethods
        
        base.class_eval do
          attr_accessor :skip_callbacks
          def self.callbacks
            @callbacks ||= {}
            @callbacks[self.name] ||= {:before_validation_on_create => [], 
              :before_validation_on_update => [], :before_validation_on_save => [], :before_create => [], 
              :after_create => [], :before_update => [], :after_update => [],
              :before_save => [], :after_save => [],
              :before_destroy => [], :after_destroy => []}
          end
        end
      end
      
      # Runs all callbacks on a model with the given name, i.g. :after_create.
      # 
      # This method is called by the CouchPotato::Database object when saving/destroying an object 
      def run_callbacks(name, database)
        return if skip_callbacks
        self.class.callbacks[name].uniq.each do |callback|
          Callback.new(self, callback, database).run
        end
      end
      
      module ClassMethods
        [
          :before_validation_on_create,
          :before_validation_on_update,
          :before_validation_on_save,
          :before_create,
          :before_save,
          :before_update,
          :before_destroy,
          :after_update,
          :after_save,
          :after_create,
          :after_destroy
        ].each do |callback|
          define_method callback do |*names|
            names.each do |name|
              callbacks[callback] << name
            end
          end
        end
      end
    end
  end
end