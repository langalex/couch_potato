module CouchPotatoe
  module Persistence
    class Finder
      # finds all objects of a given type by a given key
      # options: one key => value pair to search for
      def find(clazz, options = {})
        params = view_parameters(clazz, options)
        begin
          query_view params
        rescue RestClient::ResourceNotFound => e
          create_view params
          query_view params
        end
      end
      
      private
      
      def db(name = nil)
        ::CouchPotatoe::Persistence.Db(name)
      end
      
      def create_view(params)
        db.save({
          "_id" => "_design/#{params[:design_document]}", 
          :views => {
            params[:view] => {
              :map => "function(doc){emit(doc.data['#{params[:search_field]}'], doc);}"
              }
            }
          })
      end
      
      def query_view(params)
        db.view(params[:view_url], :key => params[:search_value])['rows'].map{|doc| doc['value']}
      end
      
      def view_parameters(clazz, options)
        {
          :design_document => clazz.name.underscore,
          :search_field => options.keys.first,
          :search_value => options.values.first,
          :view => "by_#{options.keys.first}",
          :view_url => "#{clazz.name.underscore}/by_#{options.keys.first}"
        }
      end
    end
  end
end