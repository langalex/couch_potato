module CouchPotato
  module Persistence
    class BulkSaveQueue < Array
      
      def save
        res = CouchPotato::Persistence.Db.bulk_save self
        self.clear
        res
      end
    end
  end
end