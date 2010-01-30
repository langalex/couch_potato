module CouchPotato
  module Validation
    module ActiveModel
      def self.included(base)
        require 'active_model'
        base.send :include, ::ActiveModel::Validations
        base.instance_eval do
          def before_validation(*names)
            names.each do |name|
              validate name
            end
          end
        end
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
