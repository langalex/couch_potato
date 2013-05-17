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
      include RunJS

      def initialize(expected_ruby, keys, values, rereduce = false)
        @expected_ruby, @keys, @values, @rereduce = expected_ruby, keys, values, rereduce
      end

      def matches?(view_spec)
        js = <<-JS
          #{File.read(File.dirname(__FILE__) + '/print_r.js')}

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
          print_r({result: reduce(keys, values, #{@rereduce})});
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
