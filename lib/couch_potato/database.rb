# frozen_string_literal: true

module CouchPotato
  class Database
    class ValidationsFailedError < ::StandardError; end
    # Pass in a cache to enable caching #load calls.
    # A cache needs to respond to #[], #[]= and #clear (just use a Hash).
    attr_accessor :cache
    cattr_accessor :default_batch_size
    self.default_batch_size = 500
    attr_reader :name # the (unresolved) name of the database unless this is the default database

    def initialize(couchrest_database, name: nil)
      @name = name
      @couchrest_database = couchrest_database
    end

    # executes a view and return the results. you pass in a view spec
    # which is usually a result of a SomePersistentClass.some_view call.
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
      id = view_cache_id(spec)
      cached = cache && id.is_a?(String) && cache[id]
      if cache
        if cached
          ActiveSupport::Notifications.instrument('couch_potato.view.cached') do
            cached
          end
        else
          cache[id] = view_without_caching(spec)
          cache[id]
        end
      else
        view_without_caching(spec)
      end
    end

    # Same as #view but instead of returning the results, it yields them
    # to a given block in batches of the given size, making multiple
    # requests with according skip/limit params sent to CouchDB.
    def view_in_batches(spec, batch_size: default_batch_size)
      rows = nil
      batch = 0
      loop do
        spec.view_parameters = spec
          .view_parameters
          .merge({limit: batch_size})
          .merge(
            if rows
              {
                startkey: rows&.last&.dig('key'),
                startkey_docid: rows&.last&.dig('id'),
                skip: 1
              }
            else
              {}
            end
          )
        result = raw_view(spec)
        rows = result['rows']
        yield process_view_results(result, spec)
        break if rows.size < batch_size

        batch += 1
      end
    end

    # returns the first result from a #view query or nil
    def first(spec)
      spec.view_parameters = spec.view_parameters.merge({ limit: 1 })
      view(spec).first
    end

    # returns th first result from a #view or raises CouchPotato::NotFound
    def first!(spec)
      first(spec) || raise(CouchPotato::NotFound)
    end

    # saves a document. returns true on success, false on failure.
    # if passed a block will:
    # * yield the object to be saved to the block and run if once before saving
    # * on conflict: reload the document, run the block again and retry saving
    def save_document(document, validate = true, retries = 0, &block)
      cache&.clear
      begin
        block&.call document
        save_document_without_conflict_handling(document, validate)
      rescue CouchRest::Conflict
        if block
          handle_write_conflict document, validate, retries, &block
        else
          raise CouchPotato::Conflict
        end
      end
    end
    alias save save_document

    # saves a document, raises a CouchPotato::Database::ValidationsFailedError on failure
    def save_document!(document)
      save_document(document) || raise(ValidationsFailedError, document.errors.full_messages)
    end
    alias save! save_document!

    def destroy_document(document)
      cache&.clear
      begin
        destroy_document_without_conflict_handling document
      rescue CouchRest::Conflict
        retry if document = document.reload
      end
    end
    alias destroy destroy_document

    # loads a document by its id(s)
    # id - either a single id or an array of ids
    # returns either a single document or an array of documents (if an array of ids was passed).
    # returns nil if the single document could not be found. when passing an array and some documents
    # could not be found these are omitted from the returned array
    def load_document(id)
      cached = cache && id.is_a?(String) && cache[id]
      if cache
        if cached
          ActiveSupport::Notifications.instrument('couch_potato.load.cached') do
            cached
          end
        else
          cache[id] = load_document_without_caching(id)
          cache[id]
        end
      else
        load_document_without_caching(id)
      end
    end
    alias load load_document

    # loads one or more documents by its id(s)
    # behaves like #load except it raises a CouchPotato::NotFound if any of the documents could not be found
    def load!(id)
      doc = load(id)
      missing_docs = id - doc.map(&:id) if id.is_a?(Array)
      raise(CouchPotato::NotFound, missing_docs.try(:join, ', ')) if doc.nil? || missing_docs.try(:any?)

      doc
    end

    def inspect #:nodoc:
      "#<CouchPotato::Database @root=\"#{couchrest_database.root}\">"
    end

    # returns the underlying CouchRest::Database instance
    attr_reader :couchrest_database

    # returns a new database instance connected to the CouchDB database
    # with the given name. the name is passed through the
    # additional_databases configuration to resolve it to a database
    # configured there.
    # if the current database has a cache, the new database will receive
    # a cleared copy of it.
    def switch_to(database_name)
      resolved_database_name = CouchPotato.resolve_database_name(database_name)
      self
        .class
        .new(CouchPotato.couchrest_database_for_name(resolved_database_name), name: database_name)
        .tap(&copy_clear_cache_proc)
    end

    # returns a new database instance connected to the default CouchDB database.
    # if the current database has a cache, the new database will receive
    # a cleared copy of it.
    def switch_to_default
      self
        .class
        .new(CouchPotato.couchrest_database)
        .tap(&copy_clear_cache_proc)
    end

    private

    def copy_clear_cache_proc
      lambda { |db|
        next unless cache

        db.cache = cache.dup
        db.cache.clear
      }
    end

    def view_without_caching(spec)
      ActiveSupport::Notifications.instrument('couch_potato.view', name: "#{spec.design_document}/#{spec.view_name}") do
        process_view_results(raw_view(spec), spec)
      end
    end

    def process_view_results(results, spec)
      processed_results = spec.process_results results
      if processed_results.respond_to?(:database=)
        processed_results.database = self
      elsif processed_results.respond_to?(:each)
        processed_results.each do |document|
          document.database = self if document.respond_to?(:database=)
        end
      end
      processed_results
    end

    def raw_view(spec)
      CouchPotato::View::ViewQuery.new(
        couchrest_database,
        spec.design_document,
        { spec.view_name => {
          map: spec.map_function,
          reduce: spec.reduce_function
        } },
        ({ spec.list_name => spec.list_function } unless spec.list_name.nil?),
        spec.lib,
        spec.language
      ).query_view!(spec.view_parameters)
    end

    def load_document_without_caching(id)
      raise "Can't load a document without an id (got nil)" if id.nil?

      ActiveSupport::Notifications.instrument('couch_potato.load') do
        if id.is_a?(Array)
          bulk_load id
        else
          instance = couchrest_database.get(id)
          instance.database = self if instance
          instance
        end
      end
    end

    def view_cache_id(spec)
      spec.send(:klass).to_s + spec.view_name.to_s + spec.view_parameters.to_s
    end

    def handle_write_conflict(document, validate, retries, &block)
      cache&.clear
      if retries == 5
        raise CouchPotato::Conflict
      else
        reloaded = document.reload
        document.attributes = reloaded.attributes
        document._rev = reloaded._rev
        save_document document, validate, retries + 1, &block
      end
    end

    def destroy_document_without_conflict_handling(document)
      document.run_callbacks :destroy do
        document._deleted = true
        couchrest_database.delete_doc document.to_hash
      end
      document._id = nil
      document._rev = nil
    end

    def save_document_without_conflict_handling(document, validate = true)
      if document.new?
        create_document(document, validate)
      else
        update_document(document, validate)
      end
    end

    def bulk_load(ids)
      return [] if ids.empty?

      response = couchrest_database.bulk_load ids
      docs = response['rows'].map { |row| row['doc'] }.compact
      docs.each do |doc|
        doc.database = self if doc.respond_to?(:database=)
      end
    end

    def create_document(document, validate)
      document.database = self

      if validate
        document.errors.clear
        return false if document.run_callbacks(:validation_on_save) do
          return false if document.run_callbacks(:validation_on_create) do
            return false unless valid_document?(document)
          end == false
        end == false
      end

      return false if document.run_callbacks(:save) do
        return false if document.run_callbacks(:create) do
          res = couchrest_database.save_doc document.to_hash
          document._rev = res['rev']
          document._id = res['id']
        end == false
      end == false

      true
    end

    def update_document(document, validate)
      if validate
        document.errors.clear
        return false if document.run_callbacks(:validation_on_save) do
          return false if document.run_callbacks(:validation_on_update) do
            return false unless valid_document?(document)
          end == false
        end == false
      end

      return false if document.run_callbacks(:save) do
        return false if document.run_callbacks(:update) do
          res = couchrest_database.save_doc document.to_hash
          document._rev = res['rev']
        end == false
      end == false

      true
    end

    def valid_document?(document)
      original_errors_hash = document.errors.to_hash
      document.valid?
      original_errors_hash.each do |k, v|
        if v.respond_to?(:each)
          v.each { |message| document.errors.add(k, message) }
        else
          document.errors.add(k, v)
        end
      end
      document.errors.empty?
    end
  end
end
