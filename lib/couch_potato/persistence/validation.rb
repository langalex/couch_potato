require 'validatable'

module CouchPotato
  module Persistence
    module Validation
      def self.included(base)
        base.send :include, Validatable
        base.class_eval do
          # Override the validate method to first run before_validation callback
          def valid?
            self.run_callbacks :before_validation, nil
            super
          end
        end
      end
    end
  end
end