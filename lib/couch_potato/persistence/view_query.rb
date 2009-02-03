module CouchPotato
  module Persistence

    class ViewQuery
      def initialize(design_document_name, view_name, map_function, reduce_function = nil, conditions = {}, view_options = {})
        @design_document_name = design_document_name
        @view_name = view_name
        @map_function = map_function
        @reduce_function = reduce_function
        @conditions = conditions
        @view_options = view_options
      end
      
      def query_view!
        begin
          query_view
        rescue RestClient::ResourceNotFound => e
          create_view
          query_view
        end
      end
      
      private
      
      def create_view
        # in couchdb 0.9 we could use only 1 view and pass reduce=false for find and count with reduce
        design_doc = db.get "_design/#{@design_document_name}" rescue nil
        design_doc ||= {'views' => {}, "_id" => "_design/#{@design_document_name}"}
        design_doc['views'][@view_name.to_s] = {
          'map' => @map_function,
          'reduce' => @reduce_function
        }
        db.save(design_doc)
      end
      
      def db(name = nil)
        ::CouchPotato::Persistence.Db(name)
      end
      
      def query_view
        db.view view_url, search_keys
      end
      
      def view_url
        "#{@design_document_name}/#{@view_name}"
      end
      
      def search_keys
        if search_values.select{|v| v.is_a?(Range)}.any?
          {:startkey => search_values.map{|v| v.is_a?(Range) ? v.first : v}, :endkey => search_values.map{|v| v.is_a?(Range) ? v.last : v}}.merge(view_options)
        elsif search_values.select{|v| v.is_a?(Array)}.any?
          {:keys => prepare_multi_key_search(search_values)}.merge(view_options)
        else
          view_options.merge(search_values.any? ? {:key => search_values} : {})
        end
      end
      
      def search_values
        conditions.to_a.sort_by{|f| f.first.to_s}.map(&:last)
      end
      
      def view_options
        @view_options
      end
      
      def conditions
        @conditions
      end
      
      def prepare_multi_key_search(values)
        array = values.select{|v| v.is_a?(Array)}.first
        index = values.index array
        array.map do |item|
          copy = values.dup
          copy[index] = item
          copy
        end
      end
    end
  end
end