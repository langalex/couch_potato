module CouchPotatoe
  module Persistence
    class Collection
      def initialize(item_class)
        @item_class = item_class
        @items = []
      end
      
      def build(attributes)
        item = @item_class.new(attributes)
        self.<< item
        item.position = self.size if item.respond_to?(:position=)
        item
      end
      
      def to_json(*args)
        {
          'json_class' => self.class.name,
          'data' => {
            'item_class' => @item_class.name,
            'items' => @items
          }
         
        }.to_json(*args)
      end
      
      def ==(other)
        other.class == self.class && other.send(:items) == items && other.send(:item_class) == item_class
      end
      
      def self.json_create(json)
        collection = self.new json['data']['item_class'].constantize
        json['data']['items'].each do |item|
          item.position = collection.size if item.respond_to?(:position=)
          collection << item
        end
        collection
      end
      
      delegate :[], :<<, :empty?, :any?, :each, :+, :size, :first, :last, :map, :inject, :join, :to => :items
      
      private
      
      attr_accessor :items, :item_class
    end
  end
end

if Object.const_defined? 'WillPaginate'
  module CouchPotatoe
    module Persistence
      class Collection
        def paginate(options = {})
          page = (options[:page] || 1).to_i
          per_page = options[:per_page] || 20
          collection = WillPaginate::Collection.new page, per_page, self.size
          items[((page - 1) * per_page)..(page * (per_page - 1))].each do |item|
            collection << item
          end
          collection
        end
      end
    end
  end
end