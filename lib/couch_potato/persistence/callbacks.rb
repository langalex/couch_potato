module CouchPotato
  module Persistence
    module Callbacks
      def self.included(base) #:nodoc:
        base.extend ClassMethods

        base.class_eval do
          attr_accessor :skip_callbacks
          def self.callbacks
            @callbacks ||= {}
            @callbacks[self.name] ||= {:before_validation => [], :before_validation_on_create => [], 
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
      def run_callbacks(name)
        return if skip_callbacks
        self.class.callbacks[name].uniq.each do |callback|
          if callback.is_a?(Symbol)
            send callback
          elsif callback.is_a?(Proc)
            callback.call self
          else
            raise "Don't know how to handle callback of type #{name.class.name}"
          end
        end
      end

      module ClassMethods
        [
          :before_validation,
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
            callbacks[callback].push *names
          end
        end
      end
    end
  end
end