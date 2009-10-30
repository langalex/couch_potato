require 'json'

module Spec
  module Matchers
    def map(document)
      CouchPotato::RSpec::MapToProxy.new(document)
    end
    
    def reduce(docs, keys)
      CouchPotato::RSpec::ReduceToProxy.new(docs, keys)
    end
    
    def rereduce(docs, keys)
      CouchPotato::RSpec::ReduceToProxy.new(docs, keys, true)
    end
  end
end

module CouchPotato
  module RSpec
    
    module RunJS
      private
      
      def run_js(js)
        path = 'couch_potato_js_runner.js'
        File.open(path, 'w') {|f| f << js}
        `js #{path}`
      end
    end
    
    
    class MapToProxy
      def initialize(input_ruby)
        @input_ruby = input_ruby
      end
      
      def to(expected_ruby)
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
          print(print_r(result));
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
          #{File.read(File.dirname(__FILE__) + '/print_r.js')}
          
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
          print(print_r({result: reduce(docs, keys, #{@rereduce})}));
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