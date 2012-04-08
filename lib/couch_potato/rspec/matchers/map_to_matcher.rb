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
          #{File.read(File.dirname(__FILE__) + '/print_r.js')}
          var doc = #{@input_ruby.to_json};
          var map = #{view_spec.map_function};
          var result = [];
          var emit = function(key, value) {
            result.push([key, value]);
          };
          map(doc);
          print_r(result);
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
