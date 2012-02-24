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

# provide same interface to errors object as in Validatable
module ::ActiveModel
  class Errors
    def errors
      self
    end
  end
end
