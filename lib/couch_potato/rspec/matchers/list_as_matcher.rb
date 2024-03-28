module CouchPotato
  module RSpec
    class ListAsProxy
      def initialize(results_ruby)
        @results_ruby = results_ruby
      end

      def as(expected_ruby)
        ListAsMatcher.new(expected_ruby, @results_ruby)
      end
    end

    class ListAsMatcher
      include ::RSpec::Matchers::Composable

      def initialize(expected_ruby, results_ruby)
        @expected_ruby = expected_ruby
        @results_ruby = results_ruby
      end

      def matches?(view_spec)
        js = <<-JS
          (function() {
            var results = #{@results_ruby.to_json};
            var listed = '';
            var list = #{view_spec.list_function};

            var getRow = function() {
              return results.rows.shift();
            };
            var send = function(text) {
              listed = listed + text;
            };
            list();
            return JSON.stringify(JSON.parse(listed));
          })()

        JS
        @actual_ruby = JSON.parse(ExecJS.eval(js))

        values_match? @expected_ruby, @actual_ruby
      end

      def failure_message
        "Expected to list as #{@expected_ruby.inspect} but got #{@actual_ruby.inspect}."
      end

      def failure_message_when_negated
        "Expected to not list as #{@expected_ruby.inspect} but did."
      end
    end
  end
end
