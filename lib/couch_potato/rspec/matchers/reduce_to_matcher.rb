module CouchPotato
  module RSpec
    class ReduceToProxy
      def initialize(docs, keys, rereduce = false)
        @docs, @keys, @rereduce = docs, keys, rereduce
      end

      def to(expected_ruby)
        ReduceToMatcher.new(expected_ruby, @docs, @keys, @rereduce)
      end
    end

    class ReduceToMatcher
      include RunJS

      def initialize(expected_ruby, docs, keys, rereduce = false)
        @expected_ruby, @docs, @keys, @rereduce = expected_ruby, docs, keys, rereduce
      end

      def matches?(view_spec)
        js = <<-JS
          sum = function(values) {
            var rv = 0;
            for (var i in values) {
              rv += values[i];
            }
            return rv;
          };

          var docs = #{@docs.to_json};
          var keys = #{@keys.to_json};
          var reduce = #{view_spec.reduce_function};
          JSON.stringify({result: reduce(docs, keys, #{@rereduce})});
        JS
        @actual_ruby = JSON.parse(run_js(js))['result']
        @expected_ruby == @actual_ruby
      end

      def failure_message_for_should
        "Expected to reduce to #{@expected_ruby.inspect} but got #{@actual_ruby.inspect}."
      end

      def failure_message_for_should_not
        "Expected not to reduce to #{@actual_ruby.inspect} but did."
      end
    end
  end
end
