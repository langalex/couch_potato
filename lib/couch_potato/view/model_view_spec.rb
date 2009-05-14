module CouchPotato
  module View
    # A view to return model instances by searching its properties
    #
    # example:
    #   view :my_view, :key => :name
    class ModelViewSpec < BaseViewSpec
      
      def view_parameters
        {:include_docs => true}.merge(super)
      end
      
      def map_function
        "function(doc) {
            emit(#{formatted_key(key)}, null);
         }"
      end
      
      def process_results(results)
        results['rows'].map do |row|
          klass.json_create row['doc']
        end
      end
      
      private
      
      def key
        options[:key]
      end
      
      def formatted_key(key)
        if key.is_a? Array
          '[' + key.map{|attribute| formatted_key(attribute)}.join(', ') + ']'
        else
          "doc['#{key}']"
        end
      end
      
    end
  end
end