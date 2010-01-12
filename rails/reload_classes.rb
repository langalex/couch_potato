module CouchPotato
  Database.class_eval do
    def load_document_with_class_reloading(id)
      begin
        load_document_without_class_reloading id
      rescue ArgumentError => e
        if(name = e.message.scan(/(can't find const|undefined class\/module) ([\w\:]+)/).first[1])
          eval name
          retry
        else
          raise e
        end
      end
    end
    
    alias_method :load_document_without_class_reloading, :load_document
    alias_method :load_document, :load_document_with_class_reloading
    alias_method :load, :load_document
  end
end

