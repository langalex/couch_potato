module CouchPotato
  module GhostAttributes #:nodoc:
    def self.included(base)
      base.class_eval do
        attr_accessor :_document
        def self.json_create_with_ghost(json)
          instance = json_create_without_ghost(json)
          instance._document = json if json
          instance
        end
        
        class << self
          alias_method_chain :json_create, :ghost
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

