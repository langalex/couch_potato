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
          instance_eval <<-EVAL
            def #{name}(view_options = {})
              rows = ViewQuery.new(self.name.underscore, #{name.inspect}, #{map_function.inspect}).query_view!(#{basic_view_options.inspect}.merge(view_options))
              rows['rows'].map{|row| self.new(row['doc'] || row['value'].merge(:_id => row['id']))}
            end
          EVAL
          
        end
          
        
        def map_function(key, properties)
          "function(doc) {
              emit(doc.#{key}, #{properties_for_map(properties)});
           }"
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
