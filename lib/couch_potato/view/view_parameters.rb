module CouchPotato
  module View
    module ViewParameters
      module_function

      def normalize_view_parameters(params)
        hash = wrap_in_hash params
        remove_nil_stale(replace_range_key(hash))
      end

      def remove_nil_stale(params)
        params.reject { |name, value| name.to_s == "stale" && value.nil? }
      end

      def wrap_in_hash(params)
        if params.is_a?(Hash)
          params
        else
          {key: params}
        end
      end

      def replace_range_key(params)
        if (key = params[:key]).is_a?(Range)
          params.delete :key
          params[:startkey] = key.first
          params[:endkey] = key.last
        end
        params
      end
    end
  end
end
