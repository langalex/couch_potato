module CouchPotato
  module Persistence
    class SimpleProperty  #:nodoc:
      attr_accessor :name, :type
      
      def initialize(owner_clazz, name, options = {})
        self.name = name
        self.type = options[:type]
        owner_clazz.class_eval do
          attr_reader name, "#{name}_was"
          
          def initialize(attributes = {})
            super attributes
            attributes.each do |name, value|
              self.instance_variable_set("@#{name}_was", value)
            end if attributes
          end
          
          define_method "#{name}=" do |value|
            self.instance_variable_set("@#{name}", value)
          end
          
          define_method "#{name}?" do
            !self.send(name).nil? && !self.send(name).try(:blank?)
          end
          
          define_method "#{name}_changed?" do
            !self.instance_variable_get("@#{name}_not_changed") && self.send(name) != self.send("#{name}_was")
          end
          
          define_method "#{name}_not_changed" do
            self.instance_variable_set("@#{name}_not_changed", true)
          end
        end
      end
      
      def build(object, json)
        value = json[name.to_s] || json[name.to_sym]
        typecasted_value =  if type
                              type.json_create value
                            else
                              value
                            end
        object.send "#{name}=", typecasted_value
      end
      
      def dirty?(object)
        object.send("#{name}_changed?")
      end
      
      def save(object)
        
      end
      
      def destroy(object)
        
      end
      
      def serialize(json, object)
        json[name] = object.send name
      end
    end
  end
end