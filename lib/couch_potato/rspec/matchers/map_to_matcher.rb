require 'json'


module CouchPotato
  module RSpec
    class MapToProxy
      def initialize(input_ruby)
        @input_ruby = input_ruby
      end

      def to(*expected_ruby)
        MapToMatcher.new(expected_ruby, @input_ruby)
      end
    end

    class MapToMatcher
      include RunJS

      def initialize(expected_ruby, input_ruby)
        @expected_ruby = expected_ruby
        @input_ruby = input_ruby
      end

      def matches?(view_spec)
        js = <<-JS
          var doc = #{@input_ruby.to_json};
          var map = #{view_spec.map_function};
          var lib = #{view_spec.respond_to?(:lib) && view_spec.lib.to_json};
          var result = [];
          var require = function(modulePath) {
            var exports = {};
            var pathArray = modulePath.split("/").slice(2);
            var result = lib;
            for (var i in pathArray) {
              result = result[pathArray[i]]
            }
            eval(result);
            return exports;
          }

          var emit = function(key, value) {
            result.push([key, value]);
          };
          map(doc);
          JSON.stringify(result);
        JS
        @actual_ruby = JSON.parse(run_js(js))
        @expected_ruby == @actual_ruby
      end

      def failure_message_for_should
        "Expected to map to #{@expected_ruby.inspect} but got #{@actual_ruby.inspect}."
      end

      def failure_message_for_should_not
        "Expected not to map to #{@actual_ruby.inspect} but did."
      end
    end
  end
end
