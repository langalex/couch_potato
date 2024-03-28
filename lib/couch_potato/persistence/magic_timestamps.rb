require "active_support/time"

module CouchPotato
  module MagicTimestamps # :nodoc:
    def self.included(base)
      base.instance_eval do
        property :created_at, type: Time
        property :updated_at, type: Time

        before_create lambda { |model|
          model.created_at ||= (Time.zone || Time).now
          clear_attribute_changes [:created_at]
          model.updated_at ||= (Time.zone || Time).now
          clear_attribute_changes [:updated_at]
        }
        before_update lambda { |model|
          model.updated_at = (Time.zone || Time).now
          clear_attribute_changes [:updated_at]
        }
      end
    end
  end
end
