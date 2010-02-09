require File.expand_path(File.dirname(__FILE__) + '/../../rails/reload_classes')

module CouchPotato

  def self.rails_init
    CouchPotato::Config.database_name = YAML::load(File.read(Rails.root.join('config/couchdb.yml')))[Rails.env]
  end

  if Rails.version >= '3'
    class Railtie < Rails::Railtie
      railtie_name :couch_potato

      config.after_initialize do |app|
        CouchPotato.rails_init
      end
    end
  else
    rails_init
  end

end
