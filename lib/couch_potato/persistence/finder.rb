require 'uri'

module CouchPotato
  module Persistence
    class Finder
      # finds all objects of a given type by the given attribute/value pairs
      # options: attribute_name => value pairs to search for
      # value can also be a range which will do a range search with startkey/endkey
      # WARNING: calling this methods creates a new view in couchdb if it's not present already so don't overuse this
      def find(clazz, conditions = {}, view_options = {})
        params = view_parameters(clazz, conditions, view_options)
        to_instances clazz, query_view!(params)
      end
      
      def count(clazz, conditions = {}, view_options = {})
        params = view_parameters(clazz, conditions, view_options)
        query_view!(params, '_count')['rows'].first.try(:[], 'value') || 0
      end
      
      private
      
      def query_view!(params, view_postfix = nil)
        begin
          query_view params, view_postfix
        rescue RestClient::ResourceNotFound => e
          create_view params
          query_view params, view_postfix
        end
      end
      
      def db(name = nil)
        ::CouchPotato::Persistence.Db(name)
      end
      
      def create_view(params)
        # in couchdb 0.9 we could use only 1 view and pass reduce=false for find and count with reduce
        design_doc = db.get "_design/#{params[:design_document]}" rescue nil
        db.save({
          "_id" => "_design/#{params[:design_document]}",
          :views => {
            params[:view] => {
              :map => map_function(params)
            },
            params[:view] + '_count' => {
              :map => map_function(params),
              :reduce => "function(keys, values) {
                return values.length;
              }"
            }
          }
        }.merge(design_doc ? {'_rev' => design_doc['_rev']} : {}))
      end
      
      def map_function(params)
        "function(doc) {
          if(doc.ruby_class == '#{params[:class]}') {
            emit(
              [#{params[:search_fields].map{|attr| "doc[\"#{attr}\"]"}.join(', ')}], doc
                );
          }
        }"
      end
      
      def to_instances(clazz, query_result)
        query_result['rows'].map{|doc| doc['value']}.map{|json| clazz.json_create json}
      end
      
      def query_view(params, view_postfix)
        db.view params[:view_url] + view_postfix.to_s, search_keys(params)
      end
      
      def search_keys(params)
        if params[:search_values].select{|v| v.is_a?(Range)}.any?
          {:startkey => params[:search_values].map{|v| v.is_a?(Range) ? v.first : v}, :endkey => params[:search_values].map{|v| v.is_a?(Range) ? v.last : v}}.merge(params[:view_options])
        elsif params[:search_values].select{|v| v.is_a?(Array)}.any?
          {:keys => prepare_multi_key_search(params[:search_values])}.merge(params[:view_options])
        else
          {:key => params[:search_values]}.merge(params[:view_options])
        end
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
      
      def view_parameters(clazz, conditions, view_options)
        {
          :class => clazz,
          :design_document => clazz.name.underscore,
          :search_fields => conditions.to_a.sort_by{|f| f.first.to_s}.map(&:first),
          :search_values => conditions.to_a.sort_by{|f| f.first.to_s}.map(&:last),
          :view_options => view_options,
          :view => "by_#{view_name(conditions)}",
          :view_url => "#{clazz.name.underscore}/by_#{view_name(conditions)}"
        }
      end
      
      def view_name(options)
        options.to_a.sort_by{|f| f.first.to_s}.map(&:first).join('_and_')
      end
    end
  end
end