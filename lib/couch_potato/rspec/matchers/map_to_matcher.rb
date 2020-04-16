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
      include ::RSpec::Matchers::Composable

      def initialize(expected_ruby, input_ruby)
        @expected_ruby = expected_ruby
        @input_ruby = input_ruby
      end

      def matches?(view_spec)
        js = <<-JS
          (function() {
            var doc = #{@input_ruby.to_json};
            var map = #{view_spec.map_function};
            var lib = #{view_spec.respond_to?(:lib) && view_spec.lib.to_json};
            var result = [];
            var require = function(modulePath) {
              var module = {exports: {}};
              var exports = module.exports;
              var pathArray = modulePath.split("/").slice(2);
              var result = lib;
              for (var i in pathArray) {
                result = result[pathArray[i]];
              }
              eval(result);
              return module.exports;
            }

            var emit = function(key, value) {
              result.push([key, value]);
            };
            map(doc);
            return JSON.stringify(result);
          })()
        JS
        @actual_ruby = JSON.parse(ExecJS.eval(js))
        values_match? @expected_ruby, @actual_ruby
      end

      def failure_message
        "Expected to map to #{@expected_ruby.inspect} but got #{@actual_ruby.inspect}."
      end

      def failure_message_when_negated
        "Expected not to map to #{@actual_ruby.inspect} but did."
      end
    end
  end
end
