require 'active_model'
require 'active_model/translation'

module CouchPotato
  module Validation
    def self.included(base) #:nodoc:
      base.send :include, ::ActiveModel::Validations
      base.send :include, ::ActiveModel::Validations::Callbacks
    end
  end
end
