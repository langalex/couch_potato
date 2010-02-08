require File.expand_path(File.dirname(__FILE__) + '/../../rails/reload_classes')

module CouchPotato
  if Rails.version >= '3'
    class Railtie < Rails::Railtie
      railtie_name :couch_potato

      config.after_initialize do |app|
        CouchPotato::Config.database_name = YAML::load(File.read(Rails.root.join 'config/couchdb.yml'))[Rails.env]
        Rails.logger.info "** couch_potato: initialized from #{__FILE__}"
      end
    end
  end
end
