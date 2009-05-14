module CouchPotato
  module MagicTimestamps #:nodoc:
    def self.included(base)
      base.instance_eval do
        property :created_at, :type => Time
        property :updated_at, :type => Time
        
        before_create lambda {|model| model.created_at = Time.now; model.created_at_not_changed}
        before_save lambda {|model| model.updated_at = Time.now; model.updated_at_not_changed}
      end
    end
  end
end