module CouchPotato
  module Persistence
    module Json
      def self.included(base)
        base.extend ClassMethods
      end
      
      def to_json(*args)
        to_hash.to_json(*args)
      end
      
      def to_hash
        (self.class.properties).inject({}) do |props, property|
          property.serialize(props, self)
          props
        end.merge('ruby_class' => self.class.name).merge(id_and_rev_json)
      end
      
      private
      
      def id_and_rev_json
        ['_id', '_rev', '_deleted'].inject({}) do |hash, key|
          hash[key] = self.send(key) unless self.send(key).nil?
          hash
        end
      end
      
      module ClassMethods
        def json_create(json)
          instance = self.new
          instance._id = json[:_id] || json['_id']
          instance._rev = json[:_rev] || json['_rev']
          properties.each do |property|
            property.build(instance, json)
          end
          instance
        end
      end
    end
  end
end
