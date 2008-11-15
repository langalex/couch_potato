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
      
      def dirty?(object)
        object.send("#{name}").dirty?
      end
      
      def save(object)
        object.send(name).owner_id = object._id
        object.send(name).each do |item|
          item.send("#{@owner_clazz.name.underscore}_id=", object.id)
          begin
            item.bulk_save_queue.push_queue object.bulk_save_queue
            item.save
          ensure
            item.bulk_save_queue.pop_queue
          end
        end
      end
      
      def destroy(object)
        object.send(name).each do |item|
          if dependent == :destroy
            begin
              item.bulk_save_queue.push_queue object.bulk_save_queue
              item.destroy
            ensure
              item.bulk_save_queue.pop_queue
            end
          else
            item.send("#{@owner_clazz.name.underscore}_id=", nil)
          end
        end
      end
      
      def build(object, json)
        collection = ExternalCollection.new(item_class_name.constantize, "#{@owner_clazz.name.underscore}_id")
        collection.owner_id = object.id
        object.send("#{name}").clear
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