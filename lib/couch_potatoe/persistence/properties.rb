module CouchPotatoe
  module Persistence
    module Properties
      def self.included(base)
        base.extend ClassMethods
        base.class_eval do
          def self.properties
            @@properties ||= {}
            @@properties[self.name] ||= []
          end
        end
      end
      
      module ClassMethods
        def property(name, options = {})
          properties << name
          attr_accessor name
        end

        def belongs_to(name, options = {})
          property name
          property "#{name}_id"
        end

        def has_many(name, options = {})
          property name
          getter =  <<-GETTER
            def #{name}
              @#{name} ||= #{collection_code(name.to_s.singularize.camelize, options[:stored])}
            end
          GETTER
          self.class_eval getter, 'persistence.rb', 154
        end
        
        private
        
        def collection_code(item_class, storage)
          if storage == :separately
            "CouchPotatoe::Persistence::LazyCollection.new(#{item_class}, :#{self.name.split('::').last.underscore}_id)"
          else
            "CouchPotatoe::Persistence::InlineCollection.new(#{item_class})"
          end
        end
      end
    end
    
    
  end
end