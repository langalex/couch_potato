module CouchPotato
  module View
    class BaseViewSpec
      attr_reader :reduce_function, :design_document, :view_name, :view_parameters, :klass, :options
      private :klass, :options

      def initialize(klass, view_name, options, view_parameters)
        normalized_view_parameters = normalize_view_parameters view_parameters
        assert_valid_view_parameters normalized_view_parameters
        @klass = klass
        @design_document = klass.to_s.underscore
        @view_name = view_name
        @options = options
        @view_parameters = {}
        [:group, :include_docs, :descending, :group_level, :limit].each do |key|
          @view_parameters[key] = options[key] if options.include?(key)
        end
        @view_parameters.merge!(normalized_view_parameters)
      end

      def process_results(results)
        results
      end
      
      private
      
      def normalize_view_parameters(params)
        normalized_params = params.dup
        hash = wrap_in_hash params
        replace_range_key hash
      end
      
      def wrap_in_hash(params)
        if params.is_a?(Hash)
          params
        else
          {:key => params}
        end
      end
      
      def replace_range_key(params)
        if((key = params[:key]).is_a?(Range))
          params.delete :key
          params[:startkey] = key.first
          params[:endkey] = key.last
        end
        params
      end
      
      def assert_valid_view_parameters(params)
        params.keys.each do |key|
          raise ArgumentError.new("invalid view parameter: #{key}") unless valid_view_parameters.include?(key.to_s)
        end
      end
      
      def valid_view_parameters
        %w(key startkey startkey_docid endkey endkey_docid limit stale descending skip group group_level reduce include_docs inclusive_end)
      end
    end
  end
end