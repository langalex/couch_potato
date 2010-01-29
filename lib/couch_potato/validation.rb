module CouchPotato
  module Validation
    def self.included(base) #:nodoc:
      case CouchPotato::Config.validation_framework
      when :validatable
        base.send :include, Validatable
      when :active_model
        base.send :include, ::ActiveModel::Validations
      else
        raise "Unknown CouchPotato::Config.validation_framework #{CouchPotato::Config.validation_framework.inspect}, options are :validatable or :active_model"
      end
    end
  end
end