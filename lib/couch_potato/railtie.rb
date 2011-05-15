require File.expand_path(File.dirname(__FILE__) + '/../../rails/reload_classes')
require 'erb'

module CouchPotato
  def self.rails_init
    config = YAML::load(ERB.new(File.read(Rails.root.join('config/couchdb.yml'))).result)[Rails.env]
    if config.is_a?(String)
      CouchPotato::Config.database_name = config
    else
      CouchPotato::Config.database_name = config['database']
      CouchPotato::Config.validation_framework = config['validation_framework']
      CouchPotato::Config.split_design_documents_per_view = config['split_design_documents_per_view']
    end
  end

  if defined?(::Rails::Railtie)
    class Railtie < ::Rails::Railtie
      initializer 'couch_potato.load_config' do |app|
        CouchPotato.rails_init
      end
    end
  else
    rails_init
  end
end
