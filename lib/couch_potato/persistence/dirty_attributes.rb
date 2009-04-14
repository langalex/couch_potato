module CouchPotato
  module Persistence
    module DirtyAttributes
      def dirty?
        new? || self.class.properties.inject(false) do |res, property|
          res || property.dirty?(self)
        end
      end
    end
  end
end