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
    # and also a results filter (the results will be run through the given proc):
    #   view :my_view, :key => :name, :results_filter => lambda{|results| results.size}
    class ModelViewSpec < BaseViewSpec
      class ErlangGenerator
        def initialize(options, klass)
          @options = options
          @klass = klass
        end

        def map_function
          raise NotImplementedError.new("conditions in Erlang not implemented") if @options[:conditions]
            raise NotImplementedError.new("emit_value in Erlang not implemented") if @options[:emit_value]
            <<-ERL
            fun({Doc}) ->
               case proplists:get_value(<<"#{JSON.create_id}">>, Doc) of
               <<"#{@klass.name}">> ->
                 #{formatted_key},
                 Emit(#{composite_key_brackets emit_key}, 1);
               _ ->
                 ok
               end
             end.
            ERL
        end

        private

        def composite_key_brackets(key)
          if key.include?(',')
            "[#{key}]"
          else
            key
          end
        end

        def formatted_key(_key = nil)
          _key ||= key
          if _key.is_a? Array
            parts = []
            _key.each_with_index{|k, i|
              parts << "Key_#{i} = proplists:get_value(<<\"#{k}\">>, Doc, null)"
            }
            parts.join(",\n")
          else
            "Key = proplists:get_value(<<\"#{_key}\">>, Doc, null)"
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

        def key
          @options[:key]
        end
      end

      class JavascriptGenerator
        def initialize(options, klass)
          @options = options
          @klass = klass
        end

        def map_body(&block)
          <<-JS
          function(doc) {
            if(doc.#{JSON.create_id} && doc.#{JSON.create_id} == '#{@klass.name}'#{conditions}) {
              #{yield}
            }
          }
          JS
        end

        def map_function
          map_body do
            "emit(#{formatted_key}, #{emit_value});"
          end
        end

        def formatted_key(_key = nil)
          _key ||= @options[:key]
          if _key.is_a? Array
            '[' + _key.map{|key_part| formatted_key(key_part)}.join(', ') + ']'
          else
            "doc['#{_key}']"
          end
        end

        private

        # Allow custom emit values. Raise when the specified argument is not recognized
        def emit_value
          case @options[:emit_value]
          when Symbol then "doc['#{@options[:emit_value]}']"
          when String then @options[:emit_value]
          when Numeric then @options[:emit_value]
          when NilClass then 1
          else
            raise "The emit value specified is not recognized"
          end
        end

        def conditions
          " && (#{@options[:conditions]})" if @options[:conditions]
        end
      end

      delegate :map_function, :map_body, :formatted_key, :to => :generator

      def view_parameters
        _super = super
        if _super[:reduce]
          _super
        else
          {:include_docs => true, :reduce => false}.merge(_super)
        end
      end

      def reduce_function
        "_sum"
      end

      def process_results(results)
        processed = if count?
                      results['rows'].first.try(:[], 'value') || 0
                    else
                      results['rows'].map {|row|
                        row['doc'] || (row['id'] unless view_parameters[:include_docs])
                      }.compact
                    end
        super processed
      end

      private

      def generator
        case language
        when :javascript
          @generator ||= JavascriptGenerator.new(@options, @klass)
        when :erlang
          @generator ||= ErlangGenerator.new(@options, @klass)
        else
          invalid_language
        end
      end

      def count?
        view_parameters[:reduce]
      end

      def invalid_language
        raise "unsupported language #{language}"
      end

    end
  end
end
