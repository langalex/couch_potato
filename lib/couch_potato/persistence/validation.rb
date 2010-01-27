module CouchPotato
  module Persistence
    module Validation
      def self.included(base) #:nodoc:

        case CouchPotato::Config.validation_framework
        when :validatable
          require 'validatable'
          base.send :include, Validatable
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
        when :active_model
          base.send :include, ::ActiveModel::Validations
        else
          raise "Unknown CouchPotato::Config.validation_framework #{CouchPotato::Config.validation_framework.inspect}, options are :validatable or :active_model"
        end

      end
    end
  end
end