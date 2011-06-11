module CouchPotato
  module View
    # A view to return model instances by searching its properties.
    # If you pass reduce => true will count instead
    #
    # example:
    #   view :my_view, :key => :name
    # 
    # in addition you can pass in conditions as a javascript string
    #   view :my_view_only_completed, :key => :name, :conditions => 'doc.completed = true'
    #
    # doing statistics is also possible by giving custom emit and reduce functions (couchdb >= 0.11)
    #   view :my_statistics_view, :key => :my_number, :emit => :my_number, :reduce_function => '_stats'
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
        map_body do
          "emit(#{formatted_key(key)}, #{emit_value});"
        end
      end

      # Allow custom emit values
      def emit_value
        case options[:emit]
        when Symbol then "doc['#{options[:emit]}']"
        when String then options[:emit]
        else
          1
        end
      end
      
      def reduce_function
        case options[:reduce_function]
        when String then options[:reduce_function]
        else
          "function(key, values) {
            return sum(values);
          }"
        end
      end
      
      def process_results(results)
        if count?
          results['rows'].first.try(:[], 'value') || 0
        else
          results['rows'].map { |row| row['doc'] || row['id'] }
        end
      end
      
      private
      
      def map_body(&block)
        "function(doc) {
           if(doc.#{JSON.create_id} && doc.#{JSON.create_id} == '#{@klass.name}'#{conditions_js}) {
             " + yield + "
           }
         }"
        
      end
      
      def conditions_js
        " && (#{options[:conditions]})" if options[:conditions]
      end
      
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
