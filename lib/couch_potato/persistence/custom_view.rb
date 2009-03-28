module CouchPotato
  module Persistence
    module CustomView
      
      def self.included(base)
        base.extend ClassMethods
      end
      
      module ClassMethods
        
        def view(name, options)
          map_function = options[:map] || map_function(options[:key], options[:properties])
          basic_view_options = options[:properties] || options[:map] ? {} : {:include_docs => true}
          self.class.instance_eval do
            define_method name do |view_options = {}|
              rows = ViewQuery.new(self.name.underscore, name, map_function).query_view!(basic_view_options.merge(view_options))
              rows['rows'].map{|row|
                self.json_create(row['doc'] || row['value'].merge(:_id => row['id']))
              }
            end
          end
        end
        
        def map_function(key, properties)
          "function(doc) {
              emit(#{formatted_key(key)}, #{properties_for_map(properties)});
           }"
        end
        
        def formatted_key(key)
          if key.is_a? Array
            '[' + key.map{|attribute| formatted_key(attribute)}.join(', ') + ']'
          else
            "doc['#{key}']"
          end
          
        end
        
        def properties_for_map(properties)
          if properties.nil?
            'null'
          else
            '{' + properties.map{|p| "#{p}: doc.#{p}"}.join(', ') + '}'
          end
        end
      end
    end
  end
end
