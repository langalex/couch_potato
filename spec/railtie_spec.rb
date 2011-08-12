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
end

require 'couch_potato/railtie'

describe "railtie" do
  before(:all) do
    @validation_framework = CouchPotato::Config.validation_framework
  end
  
  after(:all) do
    CouchPotato::Config.validation_framework = @validation_framework
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
      File.stub(:read => "test: \n  database: test_db\n  validation_framework: :active_model")
    end
    
    it "should set the database name from the yaml file" do
      CouchPotato::Config.should_receive(:database_name=).with('test_db')
      
      CouchPotato.rails_init
    end
    
    it "should set the validation framework from the yaml file" do
      CouchPotato::Config.should_receive(:validation_framework=).with(:active_model)
      
      CouchPotato.rails_init
    end
  end
  
  it "should process the yml file with erb" do
    File.stub(:read => "test: \n  database: <%= 'db' %>")

    CouchPotato::Config.should_receive(:database_name=).with('db')
    
    CouchPotato.rails_init
  end
end
