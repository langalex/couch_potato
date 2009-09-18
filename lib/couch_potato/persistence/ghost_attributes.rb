module CouchPotato
  module GhostAttributes
    def self.included(base)
      base.class_eval do
        attr_accessor :_document
        def self.json_create(json)
          instance = super
          instance._document = json if json
          instance
        end
        
        def method_missing(name, *args)
          if(value = _document[name.to_s])
            value
          else
            super
          end
        end
      end
    end
  end
end