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
      include RunJS
      
      def initialize(expected_ruby, results_ruby)
        @expected_ruby = expected_ruby
        @results_ruby = results_ruby
      end
      
      def matches?(view_spec)
        js = <<-JS
          #{File.read(File.dirname(__FILE__) + '/print_r.js')}
          #{File.read(File.dirname(__FILE__) + '/json2.js')}
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
          print(print_r(JSON.parse(listed)));
        JS
        
        @actual_ruby = JSON.parse(run_js(js))
        
        @expected_ruby == @actual_ruby
      end
      
      def failure_message_for_should
        "Expected to list as #{@expected_ruby.inspect} but got #{@actual_ruby.inspect}."
      end
      
      def failure_message_for_should_not
        "Expected to not list as #{@expected_ruby.inspect} but did."
      end
      
    end
  end
end