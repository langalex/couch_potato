require 'uri'

module CouchPotato
  module Persistence
    class Finder
      # finds all objects of a given type by the given attribute/value pairs
      # options: attribute_name => value pairs to search for
      # WARNING: calling this methods creates a new view in couchdb if it's not resent already so don't overuse this
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
        ::CouchPotato::Persistence.Db(name)
      end
      
      def create_view(params)
        db.save({
          "_id" => "_design/#{params[:design_document]}", 
          :views => {
            params[:view] => {
              :map => "function(doc) {
                if(doc.ruby_class == '#{params[:class]}') {
                  emit(
                    [#{params[:search_fields].map{|attr| "doc[\"#{attr}\"]"}.join(', ')}], doc
                      );
                }
              }"
            }
          }})
      end
      
      def query_view(params)
        db.view(params[:view_url], :key => (params[:search_values]))['rows'].map{|doc| doc['value']}.map{|json| params[:class].json_create json}
      end
      
      def view_parameters(clazz, options)
        {
          :class => clazz,
          :design_document => clazz.name.underscore,
          :search_fields => options.to_a.sort_by{|f| f.first.to_s}.map(&:first),
          :search_values => options.to_a.sort_by{|f| f.first.to_s}.map(&:last),
          :view => "by_#{view_name(options)}",
          :view_url => "#{clazz.name.underscore}/by_#{view_name(options)}"
        }
      end
      
      def view_name(options)
        options.to_a.map(&:first).join('_and_')
      end
    end
  end
end