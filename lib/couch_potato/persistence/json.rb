require "active_support/core_ext/hash"

module CouchPotato
  module Persistence
    module Json
      def self.included(base) # :nodoc:
        base.class_eval do
          extend ClassMethods
          attr_writer :_document

          def _document
            @_document ||= {}
          end
        end
      end

      # returns a JSON representation of a model in order to store it in CouchDB
      def to_json(*)
        to_hash.to_json(*)
      end

      # returns all the attributes, the ruby class and the _id and _rev of a model as a Hash
      def to_hash
        self.class.properties.each_with_object({}) do |property, props|
          property.serialize(props, self)
        end.merge(JSON.create_id => self.class.name).merge(id_and_rev_json)
      end

      private

      def id_and_rev_json
        ["_id", "_rev", "_deleted"].each_with_object({}) do |key, hash|
          hash[key] = send(key) unless send(key).nil?
        end
      end

      module ClassMethods
        # creates a model instance from JSON
        def json_create(json)
          return if json.nil?
          instance = new _document: HashWithIndifferentAccess.new(json)
          instance._id = json[:_id] || json["_id"]
          instance._rev = json[:_rev] || json["_rev"]
          instance
        end
      end
    end
  end
end
