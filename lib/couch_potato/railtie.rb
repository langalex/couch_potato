# frozen_string_literal: true

require 'erb'

module CouchPotato
  def self.rails_init
    require File.expand_path(File.dirname(__FILE__) + '/../../rails/reload_classes') if Rails.env.development?
    path = Rails.root.join('config/couchdb.yml')
    if File.exist?(path)
      require 'yaml'
      config = YAML.safe_load(ERB.new(File.read(path)).result, [Symbol])[Rails.env]
      CouchPotato.configure(config)
    else
      Rails.logger.warn 'Rails.root/config/couchdb.yml does not exist. Not configuring a database.'
    end
  end

  if defined?(::Rails::Railtie)
    class Railtie < ::Rails::Railtie
      initializer 'couch_potato.load_config' do |_app|
        CouchPotato.rails_init
      end
    end
  else
    rails_init
  end
end
