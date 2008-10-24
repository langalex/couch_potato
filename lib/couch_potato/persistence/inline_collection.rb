require File.dirname(__FILE__) + '/collection'

module CouchPotato
  module Persistence
    class InlineCollection < Collection
      
      def to_json(*args)
        @items.to_json(*args)
      end
      
    end
  end
end

