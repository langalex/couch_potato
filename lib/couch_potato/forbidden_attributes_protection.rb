module CouchPotato
  module ForbiddenAttributesProtection
    def self.included(base)
      base.class_eval do
        if defined?(ActiveModel::ForbiddenAttributesProtection)
          include ActiveModel::ForbiddenAttributesProtection

          def attributes=(attributes)
            super sanitize_for_mass_assignment(attributes)
          end
        end
      end
    end
  end
end
