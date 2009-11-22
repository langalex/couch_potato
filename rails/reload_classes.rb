module CouchPotato
  module Persistence
    
    def self.persistent_classes #:nodoc:
      @persistent_classes ||= []
    end

    def self.reload_persistent_classes #:nodoc:
      persistent_classes.each do |clazz|
        eval clazz.name
      end
    end
    
    
    def self.included_with_class_reloading(base) #:nodoc:
      persistent_classes << base
      included_without_class_reloading(base)
    end
    
    class << self
      alias_method :included_without_class_reloading, :included
      alias_method :included, :included_with_class_reloading
    end
  end
  
  Database.class_eval do
    def load_document_with_class_reloading(id)
      Persistence.reload_persistent_classes
      load_document_without_class_reloading id
    end
    
    alias_method :load_document_without_class_reloading, :load_document
    alias_method :load_document, :load_document_with_class_reloading
    alias_method :load, :load_document
  end
end

