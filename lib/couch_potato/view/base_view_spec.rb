# frozen_string_literal: true

module CouchPotato
  module View
    class BaseViewSpec
      attr_reader :reduce_function, :lib, :list_name, :list_function, :design_document, :view_name, :klass, :options, :language
      attr_accessor :view_parameters

      private :klass, :options

      def initialize(klass, view_name, options, view_parameters)
        normalized_view_parameters = ViewParameters.normalize_view_parameters view_parameters

        @list_name = normalized_view_parameters.delete(:list) || options[:list]
        @language = options[:language] || Config.default_language

        assert_valid_view_parameters normalized_view_parameters
        @klass = klass
        @options = options
        @view_name = compute_view_name(view_name,
          options.key?(:digest_view_name) ? options[:digest_view_name] : Config.digest_view_names)
        @design_document = translate_to_design_doc_name(klass.to_s, @view_name, @list_name)
        @list_params = normalized_view_parameters.delete :list_params

        @list_function = klass.lists(@list_name) if @list_name
        @view_parameters = {}
        %i[group include_docs descending group_level limit].each do |key|
          @view_parameters[key] = options[key] if options.include?(key)
        end
        @view_parameters.merge!(normalized_view_parameters)
        @view_parameters.merge!(@list_params) if @list_params
      end

      def process_results(results)
        if (filter = options[:results_filter])
          filter.call results
        else
          results
        end
      end

      private

      def compute_view_name(view_name, digest)
        if digest
          "#{view_name}-#{Digest::MD5.hexdigest(map_function + reduce_function.to_s)}"
        else
          view_name
        end
      end

      def assert_valid_view_parameters(params)
        params.keys.each do |key|
          raise ArgumentError, "invalid view parameter: #{key}" unless valid_view_parameters.include?(key.to_s)
        end
      end

      def valid_view_parameters
        %w[list_params key keys startkey startkey_docid endkey endkey_docid limit stale descending skip group group_level reduce include_docs inclusive_end]
      end

      def translate_to_design_doc_name(klass_name, view_name, list_name)
        klass_name = klass_name.dup
        klass_name.gsub!(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
        klass_name.gsub!(/([a-z\d])([A-Z])/, '\1_\2')
        klass_name.tr!("-", "_")
        doc_name = klass_name.downcase

        if CouchPotato::Config.split_design_documents_per_view
          doc_name += "_view_#{view_name}" if view_name.present?
          doc_name += "_list_#{list_name}" if list_name.present?
        end
        doc_name
      end
    end
  end
end
