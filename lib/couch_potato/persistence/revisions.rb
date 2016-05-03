module CouchPotato
  module Persistence
    module Revisions
      # returns all available revisions of a document, first to last.
      # causes n+1 requests. do not use in production code.
      def _revisions
        with_revs = database.couchrest_database.get(id, revs: true, revs_info: true)._document
        revs_info = with_revs[:_revs_info]
        revs = revs_info.select {|info| info[:status] == 'available' }.map {|info| info[:rev] }
        revs.reverse.map {|rev| database.couchrest_database.get(id, rev: rev) }
      end
    end
  end
end
