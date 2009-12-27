module CouchPotato
  class Database

    class ValidationsFailedError < ::StandardError; end

    def initialize(couchrest_database)
      @database = couchrest_database
      begin
        couchrest_database.info
      rescue RestClient::ResourceNotFound
        raise "Database '#{couchrest_database.name}' does not exist."
      end
    end

    def view(spec)
      results = CouchPotato::View::ViewQuery.new(database,
        spec.design_document, spec.view_name, spec.map_function,
        spec.reduce_function).query_view!(spec.view_parameters)
      spec.process_results results
    end


    def save_document(document, validate = true)
      return true unless document.dirty?
      if document.new?
        create_document(document, validate)
      else
        update_document(document, validate)
      end
    end
    alias_method :save, :save_document

    def save_document!(document)
      save_document(document) || raise(ValidationsFailedError.new(document.errors.full_messages))
    end
    alias_method :save!, :save_document!

    def destroy_document(document)
      document.run_callbacks :before_destroy
      document._deleted = true
      database.delete_doc document.to_hash
      document.run_callbacks :after_destroy
      document._id = nil
      document._rev = nil
    end
    alias_method :destroy, :destroy_document

    def load_document(id)
      raise "Can't load a document without an id (got nil)" if id.nil?
      begin
        instance = database.get(id)
        instance.database = self
        instance
      rescue(RestClient::ResourceNotFound)
        nil
      end
    end
    alias_method :load, :load_document

    def inspect
      "#<CouchPotato::Database>"
    end

    private

    def create_document(document, validate)
      document.database = self
      
      if validate
        document.errors.clear
        document.run_callbacks :before_validation_on_save
        document.run_callbacks :before_validation_on_create
        return false unless valid_document?(document)
      end
      
      document.run_callbacks :before_save
      document.run_callbacks :before_create
      res = database.save_doc document.to_hash
      document._rev = res['rev']
      document._id = res['id']
      document.run_callbacks :after_save
      document.run_callbacks :after_create
      true
    end

    def update_document(document, validate)
      if validate
        document.errors.clear
        document.run_callbacks :before_validation_on_save
        document.run_callbacks :before_validation_on_update
        return false unless valid_document?(document)
      end
      
      document.run_callbacks :before_save
      document.run_callbacks :before_update
      res = database.save_doc document.to_hash
      document._rev = res['rev']
      document.run_callbacks :after_save
      document.run_callbacks :after_update
      true
    end

    def valid_document?(document)
      errors = document.errors.errors.dup
      document.valid?
      errors.each do |k, v|
        v.each {|message| document.errors.add(k, message)}
      end
      document.errors.empty?
    end
    
    def database
      @database
    end

  end
end