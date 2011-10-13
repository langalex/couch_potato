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
          case language
          when :javascript
            "emit(#{formatted_key}, #{emit_value});"
          when :erlang
            "#{formatted_key},
            Emit(#{composite_key_brackets emit_key}, 1);"
          else
            invalid_language
          end
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
        "_sum"
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
        case language
        when :javascript
          "function(doc) {
             if(doc.#{JSON.create_id} && doc.#{JSON.create_id} == '#{@klass.name}'#{conditions}) {
               " + yield + "
             }
           }"
        when :erlang
          raise NotImplementedError.new("conditions in #{language} not implemented") if options[:conditions]
          raise NotImplementedError.new("emit_value in #{language} not implemented") if options[:emit_value]
          <<-ERL
          fun({Doc}) ->
             case proplists:get_value(<<"#{JSON.create_id}">>, Doc) of
             <<"#{@klass.name}">> ->
               #{yield}
             _ ->
               ok
             end
           end.
          ERL
        else
          invalid_language
        end
      end

      def composite_key_brackets(key)
        if key.include?(',')
          "[#{key}]"
        else
          key
        end
      end

      def emit_key
        if key.is_a?(Array)
          parts = []
          key.each_with_index{|k, i|
            parts << "Key_#{i}"
          }
          parts.join(', ')
        else
          'Key'
        end
      end

      def conditions
        " && (#{options[:conditions]})" if options[:conditions]
      end

      def count?
        view_parameters[:reduce]
      end

      def key
        options[:key]
      end

      def formatted_key(_key = nil)
        _key ||= key
        case language
        when :javascript
          if _key.is_a? Array
            '[' + _key.map{|key_part| formatted_key(key_part)}.join(', ') + ']'
          else
            "doc['#{_key}']"
          end
        when :erlang
          if _key.is_a? Array
            parts = []
            _key.each_with_index{|k, i|
              parts << "Key_#{i} = proplists:get_value(<<\"#{k}\">>, Doc, null)"
            }
            parts.join(",\n")
          else
            "Key = proplists:get_value(<<\"#{_key}\">>, Doc, null)"
          end
        else
          invalid_language
        end
      end

      def invalid_language
        raise "unsupported language #{language}"
      end

    end
  end
end
