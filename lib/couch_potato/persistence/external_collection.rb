require File.dirname(__FILE__) + '/collection'
require File.dirname(__FILE__) + '/finder'

module CouchPotato
  module Persistence
    class ExternalCollection < Collection
      
      attr_accessor :item_ids, :owner_id
      
      def initialize(item_class, owner_id_attribute_name)
        super item_class
        @items = nil
        @owner_id_attribute_name = owner_id_attribute_name
      end
      
      def build(attributes = {})
        item = @item_class.new(attributes)
        self.<< item
        item.position = self.size if item.respond_to?(:position=)
        item.send "#{@owner_id_attribute_name}=", owner_id
        item
      end
      
      def create(attributes = {})
        item = build(attributes)
        item.save
        item
      end
      
      def create!(attributes = {})
        item = build(attributes)
        item.save!
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
      
      def destroy
        @items.each do |item|
          item.destroy
        end
      end
      
      def nullify
        @items.each do |item|
          item.send "#{@owner_id_attribute_name}=", nil
          item.save
        end
      end
      
    end
  end
end

