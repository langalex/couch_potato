module CouchPotatoe
  module Persistence
    module ClassMethods
      
      def create!(attributes)
        record = self.new attributes
        record.save!
        record
      end
      
      def json_create(json)
        record = self.new
        properties.each do |name|
          record.send("#{name}=", json['data'][name.to_s])
        end
        record.created_at = json['data']['created_at'] if json['data']['created_at']
        record.updated_at = json['data']['updated_at'] if json['data']['updated_at']
        record
        #json['data']
      end
      
      def property(name)
        properties << name
        attr_accessor name
      end
      
      def belongs_to(name)
        property name
      end
      
      def has_many(name)
        property name
        getter =  <<-GETTER
          def #{name}
            @#{name} ||= CouchPotatoe::Persistence::Collection.new(#{name.to_s.singularize.camelize})
          end
        GETTER
        self.class_eval getter, 'persistence.rb', 154
      end
      
      def before_validation_on_create(name)
        callbacks[:before_validation_on_create] << name
      end
      
      def before_create(name)
        callbacks[:before_create] << name
      end
      
      def after_update(name)
        callbacks[:after_update] << name
      end
      
      def before_update(name)
        callbacks[:before_update] << name
      end
      
      def find(id)
        db.get(id)
      end
      
      def db(name = nil)
        ::CouchPotatoe::Persistence.Db(name)
      end
    end
    
  end
end