require 'spec_helper'

describe CouchPotato, 'full_url_to_database' do
  before(:each) do
    @original_database_name = CouchPotato::Config.database_name
  end
  after(:each) do
    CouchPotato::Config.database_name = @original_database_name
  end
  
  it "should add the default localhost and port if only a name is set" do
    CouchPotato::Config.database_name = 'test'
    CouchPotato.full_url_to_database.should == 'http://127.0.0.1:5984/test'
  end
  
  it "should return the set url" do
    CouchPotato::Config.database_name = 'http://db.local/test'
    CouchPotato.full_url_to_database.should == 'http://db.local/test'
  end
end

describe CouchPotato, '.models' do
  it "returns all classes that have implemented CouchPotato::Persistence" do
    clazz = Class.new
    clazz.send(:include, CouchPotato::Persistence)
    
    CouchPotato.models.should include(clazz)
  end
end