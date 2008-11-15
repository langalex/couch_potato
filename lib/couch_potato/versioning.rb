module CouchPotato
  module Versioning
    def self.included(base)
      base.class_eval do
        property :version
        property :master_version_id
        cattr_accessor :new_version_condition
        before_create :set_version_default
        before_update :prepare_for_new_version
        
        def self.set_version_condition(lambda)
          self.new_version_condition = lambda
        end
      end
    end
    
    def versions(version_no = nil)
      if version_no
        CouchPotato::Persistence::Finder.new.find(self.class, :version => version_no).first
      elsif version == 1
        [self]
      else
        CouchPotato::Persistence::Finder.new.find(self.class, :master_version_id => _id).sort_by(&:version)
      end
    end
    
    private
    
    def set_version_default
      self.version ||= 1
    end
    
    def prepare_for_new_version
      if new_version_condition.nil? || new_version_condition.call(self)
        copy = self.class.get self._id
        copy._id = nil
        copy._rev = nil
        copy.master_version_id = self._id
        copy.save_without_callbacks
        self.master_version_id ||= self.id
        self.version += 1
      end
    end
    
  end
end