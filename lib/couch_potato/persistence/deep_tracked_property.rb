module CouchPotato
  module Persistence
    class DeepTrackedProperty < SimpleProperty
      def initialize(owner_clazz, name, options = {})
        super
        define_accessors deep_accessors_module_for(owner_clazz), name, options
      end

      private

      def deep_accessors_module_for(clazz)
        module_for(clazz, "DeepAccessorMethods")
      end

      def define_accessors(base, name, options)
        base.class_eval do
          define_method :"#{name}=" do |value|
            typecasted_value = type_caster.cast(value, options[:type])
            instance_variable_set(:"@#{name}", typecasted_value)
          end

          define_method :"#{name}_changed?" do
            if self.class.doc_array_type?(options[:type])
              doc_array_changed?(name)
            elsif self.class.simple_array_type?(options[:type])
              simple_array_changed?(name)
            elsif self.class.doc_type?(options[:type])
              doc_changed?(name)
            else
              super()
            end
          end

          define_method :"#{name}_was" do
            @original_deep_values[name] if send(:"#{name}_changed?")
          end

          define_method :"#{name}_change" do
            if !send(:"#{name}_changed?")
              nil
            elsif self.class.doc_array_type?(options[:type])
              doc_array_change(name)
            elsif self.class.simple_array_type?(options[:type])
              simple_array_change(name)
            elsif self.class.doc_type?(options[:type])
              doc_change(name)
            else
              super()
            end
          end
        end
      end
    end
  end
end
