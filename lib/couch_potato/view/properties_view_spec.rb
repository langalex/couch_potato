module CouchPotato
  module View
    # A view to return model instances with only some properties poulated by searching its properties, e.g. for very large documents where you are only interested in some of their data
    #
    # example:
    #   view :my_view, :key => :name, :properties => [:name, :author], :type => :properties
    class PropertiesViewSpec < ModelViewSpec
      def map_function
        map_body do
          "emit(#{formatted_key(key)}, #{properties_for_map(properties)});"
        end
      end
      
      def reduce_function
        <<-JS
          function(key, values, rereduce) {
            if(rereduce) {
              return sum(values);
            } else {
              return values.length;
            }
          }
        JS
      end
      
      def process_results(results)
        results['rows'].map do |row|
          klass.json_create row['value'].merge(:_id => row['id'])
        end
      end
      
      def view_parameters
        {:include_docs => false}.merge(super)
      end
      
      private
      
      def properties
        options[:properties]
      end
      
      def properties_for_map(properties)
        '{' + properties.map{|p| "#{p}: doc.#{p}"}.join(', ') + '}'
      end
    end
  end
end
