module CouchPotato
  module Persistence
    module PropertyMethods
      private

      def load_attribute_from_document(name)
        if _document.has_key?(name)
          property = self.class.properties.find_property name
          @skip_dirty_tracking = true
          value = property.build(self, _document)
          @skip_dirty_tracking = false
          value
        end
      end
    end

    class SimpleProperty  #:nodoc:
      attr_accessor :name, :type

      def initialize(owner_clazz, name, options = {})
        self.name = name
        @setter_name = "#{name}="
        self.type = options[:type]
        @type_caster = TypeCaster.new
        owner_clazz.send :include, PropertyMethods unless owner_clazz.ancestors.include?(PropertyMethods)

        define_accessors accessors_module_for(owner_clazz), name, options
      end

      def build(object, json)
        value = json[name]
        object.send @setter_name, value
      end

      def dirty?(object)
        object.send("#{name}_changed?")
      end

      def serialize(json, object)
        json[name] = @type_caster.cast_back object.send(name)
      end
      alias :value :serialize

      private

      def module_for(clazz, module_name)
        module_name = "#{clazz.name.to_s.gsub('::', '__')}#{module_name}"
        unless clazz.const_defined?(module_name)
          accessors_module = clazz.const_set(module_name, Module.new)
          clazz.send(:include, accessors_module)
        end
        clazz.const_get(module_name)
      end

      def accessors_module_for(clazz)
        module_for(clazz, "AccessorMethods")
      end

      def define_accessors(base, name, options)
        ivar_name = "@#{name}".freeze
        base.class_eval do
          define_method name do
            load_attribute_from_document(name) unless instance_variable_defined?(ivar_name)
            value = instance_variable_get(ivar_name)
            if value.nil? && !options[:default].nil?
              default = if options[:default].respond_to?(:call)
                if options[:default].arity == 1
                  options[:default].call self
                else
                  options[:default].call
                end
              else
                clone_attribute(options[:default])
              end
              self.instance_variable_set(ivar_name, default)
              default
            else
              value
            end
          end

          define_method "#{name}=" do |value|
            typecasted_value = type_caster.cast(value, options[:type])
            send("#{name}_will_change!") unless @skip_dirty_tracking || typecasted_value == send(name)
            self.instance_variable_set(ivar_name, typecasted_value)
          end

          define_method "#{name}?" do
            !self.send(name).nil? && !self.send(name).try(:blank?)
          end
        end
      end
    end
  end
end
