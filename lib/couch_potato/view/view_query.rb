module CouchPotato
  module View
    # Used to query views (and create them if they don't exist). Usually you won't have to use this class directly. Instead it is used internally by the CouchPotato::Database.view method.
    class ViewQuery
      def initialize(couchrest_database, design_document_name, view_name, map_function, reduce_function = nil)
        @database = couchrest_database
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
        design_doc = @database.get "_design/#{@design_document_name}" rescue nil
        design_doc ||= {'views' => {}, "_id" => "_design/#{@design_document_name}"}
        design_doc['views'][@view_name.to_s] = {
          'map' => @map_function,
          'reduce' => @reduce_function
        }
        @database.save_doc(design_doc)
      end
      
      def query_view(parameters)
        @database.view view_url, parameters
      end
      
      def view_url
        "#{@design_document_name}/#{@view_name}"
      end

    end
  end
end