module CouchPotato
  module Validation
    def self.included(base) #:nodoc:
      require 'couch_potato/validation/with_active_model'
      base.send :include, CouchPotato::Validation::WithActiveModel
    end
  end
end