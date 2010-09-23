module CouchPotato
  module GhostAttributes #:nodoc:
    def self.included(base)
      base.class_eval do
        attr_accessor :_document
        def self.json_create(json)
          instance = super
          instance._document = json if json
          instance
        end
      end
    end
    
    def method_missing(name, *args)
      if(value = _document && _document[name.to_s])
        value
      else
        super
      end
    end
    
  end
end