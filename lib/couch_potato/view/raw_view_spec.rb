module CouchPotato
  module View
    # A view for custom map/reduce functions that returns the raw data from couchdb
    #
    # example:
    #   view :my_custom_view, :map => "function(doc) { emit(doc._id, null); }", :type => :raw, :reduce => nil
    # optionally you can pass in a results filter which you can use to process the raw couchdb results before returning them
    #
    # example:
    #   view :my_custom_view, :map => "function(doc) { emit(doc._id, null); }", :type => :raw, :results_filter => lambda{|results| results['rows].map{|row| row['value']}}
    #
    # example:
    #   view :my_custom_view, :map => "function(doc) { emit(doc._id, null); }", :type => :raw"
    class RawViewSpec < BaseViewSpec
      def map_function
        options[:map]
      end

      def reduce_function
        options[:reduce]
      end
    end
  end
end
