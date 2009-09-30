module CouchPotato
  module Attachments
    def self.included(base)
      base.class_eval do
        attr_writer :_attachments
        
        def _attachments
          @_attachments || {}
        end
        
        base.extend ClassMethods
      end
    end
    
    def to_hash
      if _attachments
        super.merge('_attachments' => _attachments)
      else
        super
      end
    end
    
    module ClassMethods
      def json_create(json)
        instance = super
        instance._attachments = json['_attachments'] if json
        instance
      end
    end
  end
end