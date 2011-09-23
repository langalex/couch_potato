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

      # Allow custom emit values. Raise when the specified argument is not recognized
      def emit_value
        case options[:emit_value]
        when Symbol then "doc['#{options[:emit_value]}']"
        when String then options[:emit_value]
        when Numeric then options[:emit_value]
        when NilClass then 1
        else
          raise "The emit value specified is not recognized"
        end
      end
      
      def reduce_function
        "function(key, values) {
          return sum(values);
        }"
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
