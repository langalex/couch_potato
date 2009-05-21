module CouchPotato
  module View
    # A view to return model instances by searching its properties.
    # If you pass reduce => true will count instead
    #
    # example:
    #   view :my_view, :key => :name
    class ModelViewSpec < BaseViewSpec
      
      def view_parameters
        _super = super
        if _super[:reduce]
          _super
        else
          {:include_docs => true, :reduce => false}.merge(_super)
        end
      end
      
      def map_function
        "function(doc) {
           if(doc.ruby_class && doc.ruby_class == '#{@klass.name}') {
             emit(#{formatted_key(key)}, null);
           }
         }"
      end
      
      def reduce_function
        "function(key, values) {
          return values.length;
        }"
      end
      
      def process_results(results)
        if count?
          results['rows'].first['value']
        else
          results['rows'].map do |row|
            klass.json_create row['doc']
          end
        end
      end
      
      private
      
      def count?
        view_parameters[:reduce]
      end
      
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