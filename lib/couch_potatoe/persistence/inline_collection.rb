require File.dirname(__FILE__) + '/collection'

module CouchPotatoe
  module Persistence
    class InlineCollection < Collection
      
      def to_json(*args)
        {
          'json_class' => self.class.name,
          'data' => {
            'item_class' => @item_class.name,
            'items' => @items
          }
         
        }.to_json(*args)
      end
      
      def self.json_create(json)
        collection = self.new json['data']['item_class'].constantize
        json['data']['items'].each do |item|
          item.position = collection.size if item.respond_to?(:position=)
          collection << item
        end
        collection
      end
      
    end
  end
end

