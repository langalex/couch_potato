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
