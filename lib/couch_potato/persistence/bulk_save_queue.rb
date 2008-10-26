module CouchPotato
  module Persistence
    class BulkSaveQueue
      attr_reader :callbacks
      
      def initialize
        @other_queues = []
        @callbacks = []
        @instances = []
      end
      
      def <<(instance)
        if own?
          @instances << instance
        else
          @other_queues.last << instance
        end
      end
      
      def push_queue(queue)
        @other_queues.push queue
      end
      
      def pop_queue
        @other_queues.pop
      end
      
      def own?
        @other_queues.empty?
      end
      
      def save(&callback)
        if own?
          @callbacks << callback if callback
          res = CouchPotato::Persistence.Db.bulk_save @instances
          @instances.clear
          @callbacks.each do |_callback|
            _callback.call res
          end
          @callbacks.clear
        else
          @other_queues.last.callbacks << callback if callback
        end
      end
    end
  end
end