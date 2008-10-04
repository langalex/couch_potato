module CouchPotatoe
  module Persistence
    module Json
      def self.included(base)
        base.extend ClassMethods
      end
      
      def to_json(*args)
        {
          'json_class' => self.class.name,
          'data' => (self.class.properties + [:created_at, :updated_at]).inject({}) do |props, name|
            props[name] = self.send(name) if self.send(name)
            props
          end
        }.merge(id_and_rev_json).to_json(*args)
      end
      
      private
      
      def id_and_rev_json
        [:_id, :_rev].inject({}) do |hash, key|
          hash[key] = self.send(key) unless self.send(key).nil?
          hash
        end
      end
      
      module ClassMethods
        def json_create(json)
          instance = self.new
          properties.each do |name|
            item = json['data'][name.to_s]
            item.owner_id = json['_id'] if item.respond_to?('owner_id=')
            instance.send "#{name}=", item
          end
          instance.created_at = json['data']['created_at'] if json['data']['created_at']
          instance.updated_at = json['data']['updated_at'] if json['data']['updated_at']
          instance._id = json['_id']
          instance._rev = json['_rev']
          instance
        end
      end
    end
  end
end
