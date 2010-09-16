require File.expand_path(File.dirname(__FILE__) + '/../../rails/reload_classes')

module CouchPotato

  def self.rails_init
    CouchPotato::Config.database_name = YAML::load(File.read(Rails.root.join('config/couchdb.yml')))[RAILS_ENV]
  end

  if defined?(::Rails::Railtie)
    class Railtie < ::Rails::Railtie
      config.after_initialize do |app|
        CouchPotato.rails_init
      end
    end
  else
    rails_init
  end

end
