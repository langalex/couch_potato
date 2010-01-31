module CouchPotato
  module Validation
    module WithValidatable
      def self.included(base)
        require 'validatable'
        base.send :include, ::Validatable
        base.class_eval do
          # Override the validate method to first run before_validation callback
          def valid?
            errors.clear
            run_callbacks :before_validation
            before_validation_errors = errors.errors.dup
            super
            before_validation_errors.each do |k, v|
              v.each {|message| errors.add(k, message)}
            end
            errors.empty?
          end
        end
      end
    end
  end
end

# add [] method to Validatable's implementation of the Errors class
module Validatable
  class Errors
    def [](attribute)
      [on(attribute)].flatten.compact
    end
  end
end
