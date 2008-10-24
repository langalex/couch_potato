module CouchPotato
  module Persistence
    class ExternalHasManyProperty
      attr_accessor :name
      def initialize(owner_clazz, name)
        @name, @owner_clazz = name, owner_clazz
        getter =  <<-ACCESORS
          def #{name}
            @#{name} ||= CouchPotato::Persistence::ExternalCollection.new(#{item_class_name}, :#{owner_clazz.name.underscore}_id)
          end
          
          def #{name}=(items)
            items.each do |item|
              #{name} << item
            end
          end
        ACCESORS
        owner_clazz.class_eval getter
      end
      
      def save(object)
        object.send(name).each do |item|
          item.send("#{@owner_clazz.name.underscore}_id=", object.id)
          item.save
        end
      end
      
      def build(object, json)
        collection = ExternalCollection.new(item_class_name.constantize, "#{@owner_clazz.name.underscore}_id")
        collection.owner_id = object.id
        object.send "#{name}=", collection
      end
      
      def serialize(json, object)
        nil
      end
      
      private
      
      def item_class_name
        @name.to_s.singularize.capitalize
      end
    end
  end
end