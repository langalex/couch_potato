module CouchPotato
  module Persistence
    module ActiveModelCompliance
      begin
        require 'active_model'

        def self.included(base)
          base.extend ClassMethods
        end

        def to_model
          self
        end

        def to_partial_path
          "#{self.class.name.underscore.pluralize}/#{self.class.name.underscore}"
        end

        def errors
          super || {}
        end

        def persisted?
          !self.new?
        end

        def to_key
          persisted? ? [to_param] : nil
        end

        def destroyed?
          !!_deleted
        end

        module ClassMethods
          def model_name
            @model_name ||= ::ActiveModel::Name.new(self)
          end
        end

      rescue LoadError, NameError
        # if it's not installed you probably don't want to use it anyway
      end
    end
  end
end


