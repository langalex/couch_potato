require File.expand_path(File.dirname(__FILE__) + '/../../rails/reload_classes')
require 'erb'

module CouchPotato
  def self.rails_init
    path = Rails.root.join('config/couchdb.yml')
    if File.exist?(path)
      require 'yaml'
      config = YAML::load(ERB.new(File.read(path)).result)[Rails.env]
      if config.is_a?(String)
        CouchPotato::Config.database_name = config
      else
        CouchPotato::Config.database_name = config['database']
        CouchPotato::Config.split_design_documents_per_view = config['split_design_documents_per_view'] if config['split_design_documents_per_view']
        CouchPotato::Config.digest_view_names = config['digest_view_names'] if config['digest_view_names']
        CouchPotato::Config.default_language = config['default_language'] if config['default_language']
      end
    else
      Rails.logger.warn "Rails.root/config/couchdb.yml does not exist. Not configuring a database."
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
