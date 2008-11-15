module CouchPotato
  module Persistence
    module DirtyAttributes
      def save
        if dirty?
          super 
        else
          valid?
        end
      end
      
      def dirty?
        new_document? || self.class.properties.inject(false) do |res, property|
          res || property.dirty?(self)
        end
      end
    end
  end
end