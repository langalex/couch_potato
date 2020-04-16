require 'json'

module CouchPotato
  module RSpec
    class MapReduceToProxy
      def initialize(*input_ruby)
        @input_ruby, @options = input_ruby.flatten, {}
      end

      def with_options(options)
        @options = options
        self
      end

      def to(*expected_ruby)
        MapReduceToMatcher.new(expected_ruby, @input_ruby, @options)
      end
    end

    class MapReduceToMatcher
      include ::RSpec::Matchers::Composable

      def initialize(expected_ruby, input_ruby, options)
        @expected_ruby = expected_ruby
        @input_ruby = input_ruby
        @options = options
      end

      def matches?(view_spec)
        js = <<-JS
          (function() {
            var sum = function(values) {
              return values.reduce(function(memo, value) { return memo + value; });
            };
            // Equivalents of couchdb built-in reduce functions whose names can be
            // given as the reduce function in the view_spec:
            var _sum = function(keys, values, rereduce) {
              return sum(values);
            }
            var _count = function(keys, values, rereduce) {
              if (rereduce) {
                return sum(values);
              } else {
                return values.length;
              }
            }
            var _stats = function(keys, values, rereduce) {
              var result = {sum: 0, count: 0, min: Number.MAX_VALUE, max: Number.MIN_VALUE, sumsqr: 0};
              if (rereduce) {
                for (var i in values) {
                  var value = values[i];
                  result.sum += value.sum;
                  result.count += value.count;
                  result.min = Math.min(result.min, value.min);
                  result.max = Math.max(result.max, value.max);
                  result.sumsqr += value.sumsqr;
                }
              } else {
                for (var i in values) {
                  var value = values[i];
                  result.sum += value;
                  result.count += 1;
                  result.min = Math.min(result.min, value);
                  result.max = Math.max(result.max, value);
                  result.sumsqr += Math.pow(value, 2);
                }
              }
              return result;
            }

            var docs = #{@input_ruby.to_json};
            var options = #{@options.to_json};
            var map = #{view_spec.map_function};
            var reduce = #{view_spec.reduce_function};
            var lib = #{view_spec.respond_to?(:lib) && view_spec.lib.to_json};
            var collate = (function() { var module = {exports: {}}; var exports = module.exports; eval(#{File.read(File.expand_path(File.dirname(__FILE__) + '/../../../../vendor/pouchdb-collate/pouchdb-collate.js')).to_json}); return module.exports.collate;})();

            // Map the input docs
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

            var unfilteredMapResults = [];
            var emit = function(key, value) {
              unfilteredMapResults.push({key: key, value: value});
            };
            for (var i in docs) {
              map(docs[i]);
            }

            // Filter results by key/keys/startkey/endkey (if given).
            var mapResults = [];
            if (options.key) {
              for (var r in unfilteredMapResults) {
                var result = unfilteredMapResults[r];
                if (collate(result.key, options.key) == 0)
                  mapResults.push(result);
              }
            }
            // couchdb does not support multiple keys for reduce views without group=true
            else if (options.keys && options.group) {
              for (var r in unfilteredMapResults) {
                var result = unfilteredMapResults[r];
                for (var k in options.keys) {
                  var key = options.keys[k];
                  if (collate(result.key, key) == 0) {
                    mapResults.push(result);
                    break;
                  }
                }
              }
            }
            else if (options.startkey || options.endkey) {
              for (var r in unfilteredMapResults) {
                var result = unfilteredMapResults[r];
                if (options.startkey && collate(options.startkey, result.key) > 0)
                  continue;
                if (options.endkey && collate(result.key, options.endkey) > 0)
                  continue;
                mapResults.push(result);
              }
            }
            else {
              mapResults = unfilteredMapResults;
            }

            // Group the map results, honoring the group and group_level options
            var grouped = [];
            if (options.group || options.group_level) {
              var groupLevel = options.group_level;
              if (groupLevel == "exact" || options.group == true)
                groupLevel = 9999;

              for (var mr in mapResults) {
                var mapResult = mapResults[mr];
                var groupedKey = Array.isArray(mapResult.key) ? mapResult.key.slice(0, groupLevel) : mapResult.key;
                var groupFound = false;
                for (var g in grouped) {
                  var group = grouped[g];
                  if (collate(groupedKey, group.groupedKey) == 0) {
                    group.keys.push(mapResult.key);
                    group.values.push(mapResult.value);
                    groupFound = true;
                    break;
                  }
                }

                if (!groupFound)
                  grouped.push({keys: [mapResult.key], groupedKey: groupedKey, values: [mapResult.value]});
              }
            } else {
              var group = {keys: null, groupedKey: null, values: []};
              for (var mr in mapResults)
                group.values.push(mapResults[mr].value);
              grouped.push(group);
            }

            // Reduce the grouped map results
            var results = [];
            for (var g in grouped) {
              var group = grouped[g], reduced = null;
              if (group.values.length >= 2) {
                // Split the values into two parts, reduce each part, then rereduce those results
                var mid = parseInt(group.values.length / 2);
                var keys1 = (group.keys || []).slice(0, mid),
                    values1 = group.values.slice(0, mid);
                var reduced1 = reduce(keys1, values1, false);
                var keys2 = (group.keys || []).slice(mid, group.values.length),
                    values2 = group.values.slice(mid, group.values.length);
                var reduced2 = reduce(keys2, values2, false);
                reduced = reduce(null, [reduced1, reduced2], true);
              } else {
                // Not enough values to split, so just reduce, and then rereduce the single result
                reduced = reduce(group.keys, group.values, false);
                reduced = reduce(null, [reduced], true);
              }
              results.push({key: group.groupedKey, value: reduced});
            }

            return JSON.stringify(results);
          })()
        JS
        @actual_ruby = JSON.parse(ExecJS.eval(js))
        values_match? @expected_ruby, @actual_ruby
      end

      def failure_message
        "Expected to map/reduce to #{@expected_ruby.inspect} but got #{@actual_ruby.inspect}."
      end

      def failure_message_when_negated
        "Expected not to map/reduce to #{@actual_ruby.inspect} but did."
      end
    end
  end
end
