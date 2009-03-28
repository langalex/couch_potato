module CouchPotato
  module Persistence

    class ViewQuery
      def initialize(design_document_name, view_name, map_function, reduce_function = nil)
        @design_document_name = design_document_name
        @view_name = view_name
        @map_function = map_function
        @reduce_function = reduce_function
      end
      
      def query_view!(parameters = {})
        begin
          query_view parameters
        rescue RestClient::ResourceNotFound => e
          create_view
          retry
        end
      end
      
      private
      
      def create_view
        design_doc = db.get "_design/#{@design_document_name}" rescue nil
        design_doc ||= {'views' => {}, "_id" => "_design/#{@design_document_name}"}
        design_doc['views'][@view_name.to_s] = {
          'map' => @map_function,
          'reduce' => @reduce_function
        }
        db.save_doc(design_doc)
      end
      
      def db(name = nil)
        ::CouchPotato::Persistence.Db(name)
      end
      
      def query_view(parameters)
        db.view view_url, parameters
      end
      
      def view_url
        "#{@design_document_name}/#{@view_name}"
      end
      

    end
  end
end