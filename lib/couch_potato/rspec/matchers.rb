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
  end
end


require File.dirname(__FILE__) + '/matchers/map_to_matcher'
require File.dirname(__FILE__) + '/matchers/reduce_to_matcher'

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

