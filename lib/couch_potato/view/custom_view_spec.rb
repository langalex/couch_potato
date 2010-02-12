module CouchPotato
  module View
    # a view for custom map/reduce functions that still returns model instances
    #
    # example:
    #   view :my_custom_view, :map => "function(doc) { emit(doc._id, null); }", :include_docs => true, :type => :custom, :reduce => nil
    class CustomViewSpec < BaseViewSpec
      def map_function
        options[:map]
      end
      
      def reduce_function
        options[:reduce]
      end
      
      def view_parameters
        {:include_docs => options[:include_docs] || false}.merge(super)
      end
      
      def process_results(results)
        if count?
          results['rows'].first.try(:[], 'value') || 0
        else  
          results['rows'].map do |row|
            if row['doc'].instance_of?(klass)
              row['doc']
            else
              klass.json_create row['doc'] || row['value'].merge(:_id => row['id'] || row['key'])
            end
          end
        end
      end
      
      private 
      
      def count?
        view_parameters[:reduce]
      end
      
    end
  end
end