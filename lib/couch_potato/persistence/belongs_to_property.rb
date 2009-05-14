module CouchPotato
  module Persistence
    class BelongsToProperty #:nodoc:
      attr_accessor :name
      
      def initialize(owner_clazz, name, options = {})
        self.name = name
        accessors =  <<-ACCESSORS
          def #{name}
            return @#{name} if instance_variable_defined?(:@#{name})
            @#{name} = @#{name}_id ? #{item_class_name}.find(@#{name}_id) : nil
          end
          
          def #{name}=(value)
            @#{name} = value
            if value.nil?
              @#{name}_id = nil
            else
              @#{name}_id = value.id
            end
          end
          
          def #{name}_id=(id)
            remove_instance_variable(:@#{name}) if instance_variable_defined?(:@#{name})
            @#{name}_id = id
          end
        ACCESSORS
        owner_clazz.class_eval accessors
        owner_clazz.send :attr_reader, "#{name}_id"
      end
      
      def save(object)
        
      end
      
      def dirty?(object)
        false
      end
      
      def destroy(object)
        
      end
      
      def build(object, json)
        object.send "#{name}_id=", json["#{name}_id"]
      end
      
      def serialize(json, object)
        json["#{name}_id"] = object.send("#{name}_id") if object.send("#{name}_id")
      end
      
      def item_class_name
        @name.to_s.camelize
      end
      
    end
  end
end