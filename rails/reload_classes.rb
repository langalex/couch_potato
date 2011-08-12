module CouchPotato
  
  module ClassReloading
    private
    
    def with_class_reloading(&block)
      begin
        yield
      rescue ArgumentError => e
        if(name = e.message.scan(/(can't find const|undefined class\/module) ([\w\:]+)/).try(:first).try(:[], 1))
          eval name.gsub(/\:+$/, '')
          retry
        else
          raise e
        end
      end
    end
  end
  
  View::ViewQuery.class_eval do
    include ClassReloading

    def query_view_with_class_reloading(*args)
      with_class_reloading do
        query_view_without_class_reloading(*args)
      end
    end

    alias_method :query_view_without_class_reloading, :query_view
    alias_method :query_view, :query_view_with_class_reloading
  end
  
  Database.class_eval do
    include ClassReloading

    def load_document_with_class_reloading(*args)
      with_class_reloading do
        load_document_without_class_reloading *args
      end
    end

    alias_method :load_document_without_class_reloading, :load_document
    alias_method :load_document, :load_document_with_class_reloading
    alias_method :load, :load_document
  end
end

