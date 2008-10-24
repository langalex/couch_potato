module CouchPotato
  module Persistence
    class BelongsToProperty
      attr_accessor :name
      
      def initialize(owner_clazz, name)
        self.name = name
        accessors =  <<-ACCESSORS
          def #{name}
            @#{name} || @#{name}_id ? #{item_class_name}.find(@#{name}_id) : nil
          end
          
          def #{name}=(value)
            @#{name} = value
            @#{name}_id = value.id
          end
        ACCESSORS
        owner_clazz.class_eval accessors
        owner_clazz.send :attr_accessor, "#{name}_id"
      end
      
      def save(object)
        
      end
      
      def build(object, json)
        object.send "#{name}_id=", json["#{name}_id"]
      end
      
      def serialize(json, object)
        json["#{name}_id"] = object.send("#{name}_id") if object.send("#{name}_id")
      end
      
      def item_class_name
        @name.to_s.singularize.capitalize
      end
    end
  end
end