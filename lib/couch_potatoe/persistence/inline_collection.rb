require File.dirname(__FILE__) + '/collection'

module CouchPotatoe
  module Persistence
    class InlineCollection < Collection
      
      def to_json(*args)
        @items.to_json(*args)
      end
      
    end
  end
end

