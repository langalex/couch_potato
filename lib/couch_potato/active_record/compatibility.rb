module CouchPotato
  module Persistence
    alias_method :new_record?, :new?
    
    module ClassMethods
      alias_method :find, :get
    end
  end
end
