# frozen_string_literal: true

module CouchPotato
  module View
    class BaseViewSpec
      attr_reader :reduce_function, :lib, :design_document, :view_name, :klass, :options, :language
      attr_accessor :view_parameters

      private :klass, :options

      def initialize(klass, view_name, options, view_parameters)
        normalized_view_parameters = ViewParameters.normalize_view_parameters view_parameters


        @language = options[:language] || Config.default_language

        assert_valid_view_parameters normalized_view_parameters
        @klass = klass
        @options = options
        @view_name = compute_view_name(view_name,
                                       options.key?(:digest_view_name) ? options[:digest_view_name] : Config.digest_view_names)
        @design_document = design_doc_name
        @view_parameters = {}
        %i[group include_docs descending group_level limit].each do |key|
          @view_parameters[key] = options[key] if options.include?(key)
        end
        @view_parameters.merge!(normalized_view_parameters)
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
        name = if CouchPotato::Config.single_design_document
          "#{translate_to_design_doc_name(klass.to_s, view_name)}-#{view_name}"
        else 
          view_name
        end

        if digest
          "#{name}-#{Digest::MD5.hexdigest(map_function + reduce_function.to_s)}"
        else
          name
        end
      end

      def assert_valid_view_parameters(params)
        params.keys.each do |key|
          raise ArgumentError, "invalid view parameter: #{key}" unless valid_view_parameters.include?(key.to_s)
        end
      end

      def valid_view_parameters
        %w[key keys startkey startkey_docid endkey endkey_docid limit stale descending skip group group_level reduce include_docs inclusive_end]
      end

      def design_doc_name
        if CouchPotato::Config.single_design_document
          'couch_potato'
        else
          translate_to_design_doc_name(klass.to_s, view_name)
        end
      end

      def translate_to_design_doc_name(klass_name, view_name)
        klass_name = klass_name.dup
        klass_name.gsub!(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
        klass_name.gsub!(/([a-z\d])([A-Z])/, '\1_\2')
        klass_name.tr!('-', '_')
        doc_name = klass_name.downcase

        if CouchPotato::Config.split_design_documents_per_view
          doc_name += "_view_#{view_name}" if view_name.present?
        end
        doc_name
      end
    end
  end
end
