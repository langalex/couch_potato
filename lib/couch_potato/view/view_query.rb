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
        update_view unless view_has_been_updated?
        begin
          query_view parameters
        rescue RestClient::ResourceNotFound# => e
          update_view
          retry
        end
      end

      private

      def update_view
        design_doc = @database.get "_design/#{@design_document_name}" rescue nil
        original_views = design_doc && design_doc['views'].dup
        view_updated unless design_doc.nil?
        design_doc ||= empty_design_document
        design_doc['views'][@view_name.to_s] = view_functions
        @database.save_doc(design_doc) unless original_views == design_doc['views']
      end
      
      def view_functions
        {'map' => @map_function, 'reduce' => @reduce_function}
      end
      
      def empty_design_document
        {'views' => {}, "_id" => "_design/#{@design_document_name}", "language" => "javascript"}
      end
      
      def view_has_been_updated?
        updated_views[[@design_document_name, @view_name]]
      end
      
      def view_updated
        updated_views[[@design_document_name, @view_name]] = true
      end
      
      def updated_views
        @@updated_views ||= {}
        @@updated_views
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