module CouchPotato
  module View
    # Used to query views (and create them if they don't exist). Usually you won't have to use this class directly. Instead it is used internally by the CouchPotato::Database.view method.
    class ViewQuery
      def initialize(couchrest_database, design_document_name, view, language = :javascript)
        @database = couchrest_database
        @design_document_name = design_document_name
        @view_name = view.keys[0]
        @map_function = view.values[0][:map]
        @reduce_function = view.values[0][:reduce]
        @language = language
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
        design_doc = @database.get "_design/#{@design_document_name}" rescue nil
        original_views = design_doc && design_doc['views'].dup
        view_updated
        design_doc ||= empty_design_document
        if CouchPotato::Config.single_design_document
          design_doc['views'] = all_views
          if CouchPotato::Config.digest_view_names
            design_doc['_id'] = "_design/#{@design_document_name}-#{Digest::SHA256.hexdigest(design_doc['views'].to_json)}"
          end
        else
          design_doc['views'][@view_name.to_s] = view_functions
        end
        if original_views != design_doc['views']
          @database.save_doc(design_doc) 
        end
      end

      def all_views
        CouchPotato.views.flat_map do |klass|
          specs =  klass.views.map { |view_name, view| klass.execute_view(view_name, {}) }
          specs.map do |klass_spec|
            { klass_spec.view_name => view_functions(klass_spec.map_function, klass_spec.reduce_function) }
          end
        end.inject(&:merge)
      end

      def view_functions(map_function = @map_function, reduce_function = @reduce_function)
        {'map' => map_function, 'reduce' => reduce_function}.compact
      end

      def empty_design_document
        {'views' => {}, "_id" => "_design/#{@design_document_name}", "language" => @language.to_s}
      end

      def view_has_been_updated?
        if CouchPotato::Config.single_design_document
          updated_views.any?
        else
          updated_views[[@design_document_name, @view_name]]
        end
      end

      def view_updated
        updated_views[[@design_document_name, @view_name]] = true
      end

      def updated_views
        self.class.__updated_views
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
