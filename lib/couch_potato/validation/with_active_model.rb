module CouchPotato
  module Validation
    module WithActiveModel
      def self.included(base)
        require 'active_model'
        require 'active_model/translation'
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
