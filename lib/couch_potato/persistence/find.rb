module CouchPotato
  module Persistence
    module Find
      def first(options = {})
        Finder.new.find(self, options).first
      end
      
      def all(options = {})
        Finder.new.find(self, options)
      end
      
      def count(options = {})
        Finder.new.count(self, options)
      end
    end
  end
end