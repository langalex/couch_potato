module CouchPotato
  module Persistence
    module DeepDirtyAttributes

      def self.included(base) #:nodoc:
        base.send :extend, ClassMethods
      end

      def initialize(*args, &block)
        super(*args, &block)
        reset_deep_dirty_attributes
      end

      def changed?
        super || self.class.deep_tracked_properties.any? do |property|
          send("#{property.name}_changed?")
        end
      end

      def changes
        changes = super
        if @original_deep_values
          self.class.deep_tracked_properties.each do |property|
            if send("#{property.name}_changed?")
              changes[property.name] = send("#{property.name}_change")
            else
              changes.delete property.name
            end
          end
        end
        changes
      end

      private

      def reset_dirty_attributes
        super
        reset_deep_dirty_attributes
      end

      def reset_deep_dirty_attributes
        @original_deep_values = HashWithIndifferentAccess.new
        self.class.deep_tracked_properties.each do |property|
          value = send(property.name)
          if value
            if doc?(value)
              value.send(:reset_dirty_attributes)
            elsif value.respond_to?(:each)
              value.each do |item|
                item.send(:reset_dirty_attributes) if doc?(item)
              end
            end
          end
          @original_deep_values[property.name] = clone_attribute(value)
        end
      end

      def doc_changed?(name)
        old, new = @original_deep_values[name], send(name)
        if old.nil? && new.nil?
          false
        elsif old.nil? ^ new.nil?
          true
        else
          (doc?(new) && new.changed?) || old.to_hash != new.to_hash
        end
      end

      def simple_array_changed?(name)
        @original_deep_values[name] != send(name)
      end

      def doc_array_changed?(name)
        old, new = @original_deep_values[name], send(name)
        if old.blank? && new.blank?
          false
        elsif old.blank? ^ new.blank?
          true
        else
          old != new || old.map(&:to_hash) != new.map(&:to_hash)
        end
      end

      def doc?(value)
        value && value.respond_to?(:changed?)
      end

      def doc_change(name)
        old, new = @original_deep_values[name], send(name)
        if !old || !new || old != new
          [old, new]
        else
          [old, doc_diff(old, new)]
        end
      end

      def doc_diff(old, new)
        clone = clone_attribute(old)
        clone.attributes = new.attributes
        clone.changes
      end

      def simple_array_change(name)
        value = send(name) || []
        old = @original_deep_values[name] || []
        changes = HashWithIndifferentAccess.new :added => value - old, :removed => old - value
        [old, changes]
      end

      def doc_array_change(name)
        old = @original_deep_values[name] || []
        value = send(name)

        added = value - old
        removed = old - value
        changed = value.map do |value_item|
          old_item = old.detect {|i| i == value_item}
          if old_item
            changes = doc_diff(old_item, value_item)
            unless changes.empty?
              [old_item, changes]
            end
          end
        end.compact
        changes = HashWithIndifferentAccess.new(:added => added, :removed => removed, :changed => changed)

        [old, changes]
      end

      module ClassMethods #:nodoc:
        def property(name, options = {})
          super
          if deep_trackable_type?(options[:type])
            index = properties.find_index {|p| p.name == name}
            properties.list[index] = DeepTrackedProperty.new(self, name, options)
            remove_attribute_dirty_methods_from_activesupport_module
          end
        end

        def remove_attribute_dirty_methods_from_activesupport_module
          methods = deep_tracked_property_names.flat_map {|n| [:"#{n}_changed?", :"#{n}_change", :"#{n}_was"]}
          active_support_module = send(:generated_attribute_methods)
          if active_support_module
            methods.each do |method|
              if active_support_module.instance_methods.include?(method)
                active_support_module.send :remove_method, method
              end
            end
          end
        end

        def doc_array_type?(type)
          type && type.is_a?(Array) && doc_type?(type[0])
        end

        def simple_array_type?(type)
          type && type.is_a?(Array) && !doc_type?(type[0])
        end

        def doc_type?(type)
          type &&
            type.respond_to?(:included_modules) &&
            type.included_modules.include?(DirtyAttributes)
        end

        def deep_trackable_type?(type)
          type && type.is_a?(Array) || doc_type?(type)
        end

        def deep_tracked_properties
          properties.select do |property|
            property.is_a? DeepTrackedProperty
          end
        end

        def deep_tracked_property_names
          deep_tracked_properties.map(&:name)
        end
      end
    end
  end
end
