require 'execjs'

require 'couch_potato/rspec/matchers/map_to_matcher'
require 'couch_potato/rspec/matchers/reduce_to_matcher'
require 'couch_potato/rspec/matchers/map_reduce_to_matcher'
require 'couch_potato/rspec/matchers/list_as_matcher'

module RSpec
  module Matchers
    def map(document)
      CouchPotato::RSpec::MapToProxy.new(document)
    end

    def reduce(keys, values)
      CouchPotato::RSpec::ReduceToProxy.new(keys, values)
    end

    def rereduce(keys, values)
      CouchPotato::RSpec::ReduceToProxy.new(keys, values, true)
    end

    def list(results)
      CouchPotato::RSpec::ListAsProxy.new(results)
    end

    def map_reduce(*docs)
      CouchPotato::RSpec::MapReduceToProxy.new(docs)
    end
  end
end
