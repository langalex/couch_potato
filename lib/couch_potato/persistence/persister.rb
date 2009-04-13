class Persister
  
  def initialize(database)
    @database = database
  end
  
  def save_document(document)
    if document.new?
      create_document document
    else
      update_document document
    end
  end
  
  def destroy_document(document)
    document.run_callbacks(:before_destroy)
    document._deleted = true
    database.delete_doc document.to_hash
    document.run_callbacks(:after_destroy)
    document._id = nil
    document._rev = nil
  end
  
  def inspect
    "#<Persister>"
  end
  
  private
  
  def create_document(document)
    document.run_callbacks :before_validation_on_save
    document.run_callbacks :before_validation_on_create
    return unless document.valid?
    document.run_callbacks :before_save
    document.run_callbacks :before_create
    res = database.save_doc document.to_hash
    document._rev = res['rev']
    document._id = res['id']
    document.run_callbacks :after_save
    document.run_callbacks :after_create
    true
  end
  
  def update_document(document)
    document.run_callbacks(:before_validation_on_save)
    document.run_callbacks(:before_validation_on_update)
    return unless document.valid?
    document.run_callbacks :before_save
    document.run_callbacks :before_update
    res = database.save_doc document.to_hash
    document._rev = res['rev']
    document.run_callbacks :after_save
    document.run_callbacks :after_update
    true
  end
  
  def database
    @database
  end
  
end