# frozen_string_literal: true

module CouchPotato
  module View
    # A flexible view spec.
    # It allows to either just define a key and option conditions like
    # the model view spec or custom map/reduce functions.
    # In addition, it returns a result object that allows convenient access
    # to either the raw result, the keys, values, ids or docs. The result object can
    # be extended with custom module, too.
    # Examples:
    # class Thing
    #   module ResultsExt
    #     def average_time
    #       keys.sum / keys.size # can access other result methods
    #     end
    #   end
    #   property :time
    #   view :by_time, type: :flex, key: :time, extend_results: ResultsExt
    #   view :by_custom_time, type: :flex,
    #     reduce: '_sum'
    #     map: <<~JS
    #       function(doc) {
    #         emit(doc.time, 1);
    #       }
    #     JS
    # end
    #
    # usage:
    # irb> result = db.view Thing.by_time
    # irb> result.raw # raw CouchDB results
    # irb> result.ids # ids of rows
    # irb> result.keys # keys emitted in map function
    # irb> result.values # values emitted in map function
    # irb> result.average_time # custom method from ResultsExt module
    # irb> db.view(Thing.by_time(include_docs: true)).docs # documents
    # irb> db.view(Thing.by_time(reduce: true)).reduce_value # value of first row, i.e. result of the reduce function (without grouping)
    class FlexViewSpec
      attr_reader :klass

      class Results
        attr_accessor :database # set by database

        def initialize(raw_results)
          @raw_results = raw_results
        end

        def raw
          @raw_results
        end

        def ids
          rows.map { |row| row['id'] }
        end

        def keys
          rows.map { |row| row['key'] }
        end

        def values
          rows.map { |row| row['value'] }
        end

        def reduce_value
          rows.dig(0, 'value')
        end

        # returns a count from a CouchDB reduce. returns 0 when the result
        # set is empty (which would result in `nil` when calling #reduce_value).
        # you still have to pass reduce=true to the view call.
        def reduce_count
          reduce_value || 0
        end

        def docs
          rows.map do |row|
            doc = row['doc']
            doc.database = database if doc.respond_to?(:database=)
            doc
          end
        end

        def rows
          @raw_results['rows']
        end
      end

      def initialize(klass, view_name, options, view_parameters)
        @extend_results_module = options[:extend_results]
        @klass = klass
        @view_name = view_name
        @options = options.except(:extend_results)
        @view_parameters = view_parameters
      end

      delegate :view_name, :view_parameters, :design_document, :map_function,
               :reduce_function, :list_name, :lib, :language, to: :view_spec_delegate

      def process_results(results)
        results = Results.new(results)
        results.extend @extend_results_module if @extend_results_module
        results
      end

      private

      def view_spec_delegate
        unless @view_spec_delegate
          view_spec_class = @options[:map] ? RawViewSpec : ModelViewSpec
          @view_spec_delegate = view_spec_class.new(
            @klass, @view_name, @options,
            ViewParameters
              .normalize_view_parameters(@view_parameters)
              .reverse_merge(reduce: false, include_docs: false)
          )
        end
        @view_spec_delegate
      end
    end
  end
end
