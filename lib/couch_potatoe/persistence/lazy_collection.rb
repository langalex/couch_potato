require File.dirname(__FILE__) + '/collection'
require File.dirname(__FILE__) + '/finder'

module CouchPotatoe
  module Persistence
    class LazyCollection < Collection
      
      attr_accessor :item_ids, :owner_id
      
      def initialize(item_class, owner_id_attribute_name)
        super item_class
        @items = nil
        @owner_id = owner_id
        @owner_id_attribute_name = owner_id_attribute_name
      end
      
      def build(attributes)
        item = @item_class.new(attributes)
        self.<< item
        item.position = self.size if item.respond_to?(:position=)
        item.send "#{@owner_id_attribute_name}=", owner_id
        item
      end
      
      def items
        if @items.nil?
          @items = Finder.new.find @item_class, @owner_id_attribute_name => owner_id
        end
        @items
      end
      
      def save
        items.each do |item|
          item.send "#{@owner_id_attribute_name}=", owner_id
          item.save
        end
      end
      
      def to_json(*args)
        {
          'json_class' => self.class.name,
          'data' => {
            'item_class' => @item_class.name,
            'owner_id_attribute_name' => @owner_id_attribute_name
            
          }
        }.to_json(*args)
      end
      
      def self.json_create(json)
        self.new json['data']['item_class'].constantize, json['data']['owner_id_attribute_name']
      end
      
    end
  end
end

