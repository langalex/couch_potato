module CouchPotato
  module RSpec
    class ReduceToProxy
      def initialize(keys, values, rereduce = false)
        @keys, @values, @rereduce = keys, values, rereduce
      end

      def to(expected_ruby)
        ReduceToMatcher.new(expected_ruby, @keys, @values, @rereduce)
      end
    end

    class ReduceToMatcher
      include ::RSpec::Matchers::Composable

      def initialize(expected_ruby, keys, values, rereduce = false)
        @expected_ruby, @keys, @values, @rereduce = expected_ruby, keys, values, rereduce
      end

      def matches?(view_spec)
        js = <<-JS
          (function() {
            sum = function(values) {
              var rv = 0;
              for (var i in values) {
                rv += values[i];
              }
              return rv;
            };

            var keys = #{@keys.to_json};
            var values = #{@values.to_json};
            var reduce = #{view_spec.reduce_function};
            return JSON.stringify({result: reduce(keys, values, #{@rereduce})});
          })()
        JS
        @actual_ruby = JSON.parse(ExecJS.eval(js))["result"]
        values_match? @expected_ruby, @actual_ruby
      end

      def failure_message
        "Expected to reduce to #{@expected_ruby.inspect} but got #{@actual_ruby.inspect}."
      end

      def failure_message_when_negated
        "Expected not to reduce to #{@actual_ruby.inspect} but did."
      end
    end
  end
end
