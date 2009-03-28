module CouchPotato
  module Persistence
    class SimpleProperty
      attr_accessor :name
      
      def initialize(owner_clazz, name, options = {})
        self.name = name
        owner_clazz.class_eval do
          attr_reader name, "#{name}_was"
          
          def initialize(attributes = {})
            super attributes
            attributes.each do |name, value|
              self.instance_variable_set("@#{name}_was", value)
            end if attributes
          end
          
          def self.json_create(json)
            instance = super
            instance.attributes.each do |name, value|
              instance.instance_variable_set("@#{name}_was", value)
            end
            instance
          end
          
          define_method "#{name}=" do |value|
            self.instance_variable_set("@#{name}", value)
          end
          
          define_method "#{name}?" do
            !self.send(name).nil? && !self.send(name).try(:blank?)
          end
          
          define_method "#{name}_changed?" do
            self.send(name) != self.send("#{name}_was")
          end
        end
      end
      
      def build(object, json)
        object.send "#{name}=", json[name.to_s] || json[name.to_sym]
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