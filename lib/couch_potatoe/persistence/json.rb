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
        }.to_json(*args)
      end
      
      module ClassMethods
        def json_create(json)
          record = self.new
          properties.each do |name|
            item = json['data'][name.to_s]
            item.owner_id = json['_id'] if item.respond_to?('owner_id=')
            record.send "#{name}=", item
          end
          record.created_at = json['data']['created_at'] if json['data']['created_at']
          record.updated_at = json['data']['updated_at'] if json['data']['updated_at']
          record
        end
      end
    end
  end
end
