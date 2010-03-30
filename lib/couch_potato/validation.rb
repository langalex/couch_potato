module CouchPotato
  module Validation
    def self.included(base) #:nodoc:
      case CouchPotato::Config.validation_framework
      when :validatable
        require 'couch_potato/validation/with_validatable'
        base.send :include, CouchPotato::Validation::WithValidatable
      when :active_model
        require 'couch_potato/validation/with_active_model'
        base.send :include, CouchPotato::Validation::WithActiveModel
      else
        raise "Unknown CouchPotato::Config.validation_framework #{CouchPotato::Config.validation_framework.inspect}, options are :validatable or :active_model"
      end
    end
  end
end