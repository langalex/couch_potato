module CouchPotato
  class Database

    class ValidationsFailedError < ::StandardError; end

    def initialize(couchrest_database)
      @couchrest_database = couchrest_database
      begin
        couchrest_database.info
      rescue RestClient::ResourceNotFound
        raise "Database '#{couchrest_database.name}' does not exist."
      end
    end

    # executes a view and return the results. you pass in a view spec
    # which is usually a result of a SomePersistentClass.some_view call.
    # also return the total_rows returned by CouchDB as an accessor on the results.
    #
    # Example:
    #
    #   class User
    #     include CouchPotato::Persistence
    #     property :age
    #     view :all, key: :age
    #   end
    #   db = CouchPotato.database
    #
    #   db.view(User.all) # => [user1, user2]
    #   db.view(User.all).total_rows # => 2
    #
    # You can pass the usual parameters you can pass to a couchdb view to the view:
    #
    #   db.view(User.all(limit: 5, startkey: 2, reduce: false))
    #
    # For your convenience when passing a hash with only a key parameter you can just pass in the value
    #
    #   db.view(User.all(key: 1)) == db.view(User.all(1))
    #
    # Instead of passing a startkey and endkey you can pass in a key with a range:
    #
    #   db.view(User.all(key: 1..20)) == db.view(startkey: 1, endkey: 20) == db.view(User.all(1..20))
    #
    # You can also pass in multiple keys:
    #
    #   db.view(User.all(keys: [1, 2, 3]))
    def view(spec)
      results = CouchPotato::View::ViewQuery.new(
        couchrest_database,
        spec.design_document,
        {spec.view_name => {
          :map => spec.map_function,
          :reduce => spec.reduce_function}
        },
        ({spec.list_name => spec.list_function} unless spec.list_name.nil?),
        spec.language
      ).query_view!(spec.view_parameters)
      processed_results = spec.process_results results
      processed_results.instance_eval "def total_rows; #{results['total_rows']}; end" if results['total_rows']
      processed_results.each do |document|
        document.database = self if document.respond_to?(:database=)
      end if processed_results.respond_to?(:each)
      processed_results
    end

    # returns the first result from a #view query or nil
    def first(spec)
      view(spec).first
    end

    # returns th first result from a #view or raises CouchPotato::NotFound
    def first!(spec)
      first(spec) || raise(CouchPotato::NotFound)
    end

    # saves a document. returns true on success, false on failure
    def save_document(document, validate = true)
      return true unless document.dirty? || document.new?
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
      document.run_callbacks :destroy do
        document._deleted = true
        couchrest_database.delete_doc document.to_hash
      end
      document._id = nil
      document._rev = nil
    end
    alias_method :destroy, :destroy_document

    # loads a document by its id(s)
    def load_document(id)
      raise "Can't load a document without an id (got nil)" if id.nil?
      
      if id.is_a?(Array)
        bulk_load id
      else
        begin
          instance = couchrest_database.get(id)
          instance.database = self
          instance
        rescue(RestClient::ResourceNotFound)
          nil
        end
      end
    end
    alias_method :load, :load_document

    def load!(id)
      doc = load(id)
      if id.is_a?(Array)
        missing_docs = id - doc.map(&:id)
      end
      raise(CouchPotato::NotFound, missing_docs) if doc.nil? || missing_docs
    end

    def inspect #:nodoc:
      "#<CouchPotato::Database @root=\"#{couchrest_database.root}\">"
    end

    # returns the underlying CouchRest::Database instance
    def couchrest_database
      @couchrest_database
    end

    private
    
    def bulk_load(ids)
      response = couchrest_database.bulk_load ids
      existing_rows = response['rows'].select{|row| row.key? 'doc'}
      docs = existing_rows.map{|row| row["doc"]}
      docs.each{|doc| doc.database = self}
    end

    def create_document(document, validate)
      document.database = self

      if validate
        document.errors.clear
        return false if false == document.run_callbacks(:validation_on_save) do
          return false if false == document.run_callbacks(:validation_on_create) do
            return false unless valid_document?(document)
          end
        end
      end

      return false if false == document.run_callbacks(:save) do
        return false if false == document.run_callbacks(:create) do
          res = couchrest_database.save_doc document.to_hash
          document._rev = res['rev']
          document._id = res['id']
        end
      end
      true
    end

    def update_document(document, validate)
      if validate
        document.errors.clear
        return false if false == document.run_callbacks(:validation_on_save) do
          return false if false == document.run_callbacks(:validation_on_update) do
            return false unless valid_document?(document)
          end
        end
      end

      return false if false == document.run_callbacks(:save) do
        return false if false == document.run_callbacks(:update) do
          res = couchrest_database.save_doc document.to_hash
          document._rev = res['rev']
        end
      end
      true
    end

    def valid_document?(document)
      errors = document.errors.errors.dup
      errors.instance_variable_set("@messages", errors.messages.dup) if errors.respond_to?(:messages)
      document.valid?
      errors.each do |k, v|
        if v.respond_to?(:each)
          v.each {|message| document.errors.add(k, message)}
        else
          document.errors.add(k, v)
        end
      end
      document.errors.empty?
    end
  end
end
