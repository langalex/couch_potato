module CouchPotato
  module Validation
    module WithActiveModel
      def self.included(base)
        require 'active_model'
        require 'active_model/translation'
        base.send :include, ::ActiveModel::Validations
        base.send :include, ::ActiveModel::Validations::Callbacks
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
