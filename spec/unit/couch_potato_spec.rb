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
    expect(CouchPotato.full_url_to_database).to eq('http://127.0.0.1:5984/test')
  end

  it "should return the set url" do
    CouchPotato::Config.database_name = 'http://db.local/test'
    expect(CouchPotato.full_url_to_database).to eq('http://db.local/test')
  end
end

describe CouchPotato, 'use' do
  it 'should return the db object' do
    db = CouchPotato.use("testdb")
    expect(db.couchrest_database.root.to_s).to eq('http://127.0.0.1:5984/testdb')
  end

  it 'returns a db from the additional_databases pool' do
    CouchPotato::Config.database_host = 'http://127.0.0.1:5984'
    CouchPotato::Config.additional_databases = {'1' => 'db1', '2' => 'db2'}

    db = CouchPotato.use('2')

    expect(db.couchrest_database.root.to_s).to eq('http://127.0.0.1:5984/db2')
  end
end

describe CouchPotato, '.models' do
  it "returns all classes that have implemented CouchPotato::Persistence" do
    clazz = Class.new
    clazz.send(:include, CouchPotato::Persistence)

    expect(CouchPotato.models).to include(clazz)
  end

  it 'returns all subclasses of classes that have implemented CouchPotato::Persistence' do
    clazz = Class.new
    clazz.send(:include, CouchPotato::Persistence)
    subclazz = Class.new clazz

    expect(CouchPotato.models).to include(subclazz)
  end
end
