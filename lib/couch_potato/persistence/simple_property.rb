module CouchPotato
  module Persistence
    class SimpleProperty  #:nodoc:
      attr_accessor :name, :type
      
      def initialize(owner_clazz, name, options = {})
        self.name = name
        self.type = options[:type]
        @type_caster = TypeCaster.new
        
        define_accessors accessors_module_for(owner_clazz), name, options
      end
      
      def build(object, json)
        value = json[name.to_s].nil? ? json[name.to_sym] : json[name.to_s]
        object.send "#{name}=", value
      end
      
      def dirty?(object)
        object.send("#{name}_changed?")
      end
      
      def serialize(json, object)
        json[name] = object.send name
      end
      alias :value :serialize
      
      private
      
      def accessors_module_for(clazz)
        unless clazz.const_defined?('AccessorMethods')
          accessors_module = clazz.const_set('AccessorMethods', Module.new) 
          clazz.send(:include, accessors_module)
        end
        clazz.const_get('AccessorMethods')
      end
      
      def define_accessors(base, name, options)
        base.class_eval do
          define_method "#{name}" do
            value = self.instance_variable_get("@#{name}")
            if value.nil? && options[:default]
              default = clone_attribute(options[:default])
              self.instance_variable_set("@#{name}", default)
              default
            else
              value
            end
          end
          
          define_method "#{name}=" do |value|
            typecasted_value = type_caster.cast(value, options[:type])
            send("#{name}_will_change!") unless @skip_dirty_tracking || typecasted_value == send(name)
            self.instance_variable_set("@#{name}", typecasted_value)
          end
          
          define_method "#{name}?" do
            !self.send(name).nil? && !self.send(name).try(:blank?)
          end
        end
      end
    end
  end
end
