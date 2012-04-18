require 'spec_helper'
require 'yaml'
require 'spec/mocks'

module Rails
  def self.env
    'test'
  end

  class Railtie
    def self.initializer(*args)
    end
  end

  def self.root
    RSpec::Mocks::Mock.new :join => ''
  end

  def self.logger
    RSpec::Mocks::Mock.new :warn => nil
  end
end

require 'couch_potato/railtie'

describe "railtie" do
  before(:all) do
    @database_name = CouchPotato::Config.database_name
    @default_language = CouchPotato::Config.default_language
  end

  after(:all) do
    CouchPotato::Config.database_name = @database_name
    CouchPotato::Config.default_language = @default_language
  end

  before(:each) do
    File.stub(exist?: true)
  end

  context 'when the yml file does not exist' do
    before(:each) do
      File.stub(exist?: false)
    end

    it 'does not configure the database' do
      CouchPotato::Config.should_not_receive(:database_name=)

      CouchPotato.rails_init
    end
  end

  context 'yaml file contains only database names' do
    it "should set the database name from the yaml file" do
      File.stub(:read => "test: test_db")

      CouchPotato::Config.should_receive(:database_name=).with('test_db')

      CouchPotato.rails_init
    end
  end

  context 'yaml file contains more configuration' do
    before(:each) do
      File.stub(:read => "test: \n  database: test_db\n  default_language: :erlang")
    end

    it "set the database name from the yaml file" do
      CouchPotato::Config.should_receive(:database_name=).with('test_db')

      CouchPotato.rails_init
    end

    it 'sets the default language from the yaml file' do
      CouchPotato::Config.should_receive(:default_language=).with(:erlang)

      CouchPotato.rails_init
    end
  end

  it "should process the yml file with erb" do
    File.stub(:read => "test: \n  database: <%= 'db' %>")

    CouchPotato::Config.should_receive(:database_name=).with('db')

    CouchPotato.rails_init
  end
end
