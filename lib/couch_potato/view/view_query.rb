module CouchPotato
  module View
    # Used to query views (and create them if they don't exist). Usually you won't have to use this class directly. Instead it is used internally by the CouchPotato::Database.view method.
    class ViewQuery
      def initialize(couchrest_database, design_document_name, view, list = nil, lib = nil, language = :javascript)
        @database = couchrest_database
        @design_document_name = design_document_name
        @view_name = view.keys[0]
        @map_function = view.values[0][:map]
        @reduce_function = view.values[0][:reduce]
        @lib = lib
        @language = language
        if list
          @list_function = list.values[0]
          @list_name = list.keys[0]
        end
      end

      def query_view!(parameters = {})
        update_view unless view_has_been_updated?
        begin
          query_view parameters
        rescue CouchRest::NotFound
          update_view
          retry
        end
      end

      # mainly useful for testing where you drop the database between tests.
      # only after clearing the cache design docs will be updated/re-created.
      def self.clear_cache
        __updated_views.clear
      end

      def self.__updated_views
        @updated_views ||= {}
        @updated_views
      end

      private

      def update_view
        design_doc = begin
          @database.get "_design/#{@design_document_name}"
        rescue
          nil
        end
        original_views = design_doc && design_doc["views"].dup
        original_lists = design_doc && design_doc["lists"] && design_doc["lists"].dup
        view_updated unless design_doc.nil?
        design_doc ||= empty_design_document
        design_doc["views"][@view_name.to_s] = view_functions
        if @lib
          design_doc["views"]["lib"] = (design_doc["views"]["lib"] || {}).merge(@lib)
        end
        if @list_function
          design_doc["lists"] ||= {}
          design_doc["lists"][@list_name.to_s] = @list_function
        end
        @database.save_doc(design_doc) if original_views != design_doc["views"] || original_lists != design_doc["lists"]
      end

      def view_functions
        if @reduce_function
          {"map" => @map_function, "reduce" => @reduce_function}
        else
          {"map" => @map_function}
        end
      end

      def empty_design_document
        {"views" => {}, "lists" => {}, "_id" => "_design/#{@design_document_name}", "language" => @language.to_s}
      end

      def view_has_been_updated?
        updated_views[[@design_document_name, @view_name]]
      end

      def view_updated
        updated_views[[@design_document_name, @view_name]] = true
      end

      def updated_views
        self.class.__updated_views
      end

      def query_view(parameters)
        if @list_name
          @database.connection.get CouchRest.paramify_url("/#{@database.name}/_design/#{@design_document_name}/_list/#{@list_name}/#{@view_name}", parameters)
        else
          @database.view view_url, parameters
        end
      end

      def view_url
        "#{@design_document_name}/#{@view_name}"
      end
    end
  end
end
