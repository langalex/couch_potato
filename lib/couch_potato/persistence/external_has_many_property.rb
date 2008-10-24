module CouchPotato
  module Persistence
    class ExternalHasManyProperty
      attr_accessor :name, :dependent
      def initialize(owner_clazz, name, options = {})
        @name, @owner_clazz = name, owner_clazz
        @dependent = options[:dependent] || :nullify
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
        object.send(name).owner_id = object._id
        object.send(name).each do |item|
          item.send("#{@owner_clazz.name.underscore}_id=", object.id)
          item.save
        end
      end
      
      def destroy(object)
        if dependent == :destroy
          object.send(name).destroy
        else
          object.send(name).nullify
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
        @name.to_s.singularize.camelcase
      end
    end
  end
end