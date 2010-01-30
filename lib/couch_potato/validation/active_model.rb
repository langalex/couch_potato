module CouchPotato
  module Validation
    module ActiveModel
      def self.included(base)
        require 'active_model'
        base.send :include, ::ActiveModel::Validations
      end
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
