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

    # executes a view and return the results. you pass in a view spec
    # which is usually a result of a SomePersistentClass.view call.
    # also return the total_rows returned by CouchDB as an accessor on the results.
    #
    # Example:
    #
    #   class User
    #     include CouchPotato::Persistence
    #     view :all, key: :created_at
    #   end
    #
    #   CouchPotato.database.view(User.all) # => [user1, user2]
    #   CouchPotato.database.view(User.all).total_rows # => 2
    #
    def view(spec)
      results = CouchPotato::View::ViewQuery.new(database,
        spec.design_document, spec.view_name, spec.map_function,
        spec.reduce_function).query_view!(spec.view_parameters)
      processed_results = spec.process_results results
      processed_results.instance_eval "def total_rows; #{results['total_rows']}; end" if results['total_rows']
      processed_results.each do |document|
        document.database = self if document.respond_to?(:database=)
      end if processed_results.respond_to?(:each)
      processed_results
    end

    # saves a document. returns true on success, false on failure
    def save_document(document, validate = true)
      return true unless document.dirty?
      if document.new?
        create_document(document, validate)
      else
        update_document(document, validate)
      end
    end
    alias_method :save, :save_document
    
    # saves a document, raises a CouchPotato::Database::ValidationsFailedError on failure
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

    # loads a document by its id
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

    def inspect #:nodoc:
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