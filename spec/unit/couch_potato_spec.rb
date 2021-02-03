# frozen_string_literal: true

require 'spec_helper'

describe CouchPotato, '.configure' do
  after(:example) do
    # reset defaults
    CouchPotato::Config.database_name = nil
    CouchPotato::Config.split_design_documents_per_view = false
    CouchPotato::Config.digest_view_names = false
    CouchPotato::Config.default_language = :javascript
    CouchPotato::Config.database_host = 'http://127.0.0.1:5984'
    CouchPotato::Config.additional_databases = {}
  end

  it 'sets the database name when config is a string' do
    CouchPotato.configure('testdb')

    expect(CouchPotato::Config.database_name).to eq('testdb')
  end

  it 'does not override database_host if not given' do
    CouchPotato.configure(
      database: 'testdb'
    )

    expect(CouchPotato::Config.database_host).to eq('http://127.0.0.1:5984')
  end

  it 'sets the given config options' do
    CouchPotato.configure(
      database: 'testdb',
      database_host: 'http://10.0.0.1:2000',
      additional_databases: {
        test2: 'test2_db'
      },
      split_design_documents_per_view: true,
      digest_view_names: true,
      default_language: 'erlang'
    )

    expect(CouchPotato::Config.database_name).to eq('testdb')
    expect(CouchPotato::Config.split_design_documents_per_view).to eq(true)
    expect(CouchPotato::Config.digest_view_names).to eq(true)
    expect(CouchPotato::Config.default_language).to eq('erlang')
    expect(CouchPotato::Config.database_host).to eq('http://10.0.0.1:2000')
    expect(CouchPotato::Config.additional_databases).to eq('test2' => 'test2_db')
  end

  it 'works with string keys' do
    CouchPotato.configure(
      'database' => 'testdb'
    )

    expect(CouchPotato::Config.database_name).to eq('testdb')
  end
end

describe CouchPotato, '.full_url_to_database' do
  before(:each) do
    @original_database_name = CouchPotato::Config.database_name
  end
  after(:each) do
    CouchPotato::Config.database_name = @original_database_name
  end

  it 'should add the default localhost and port if only a name is set' do
    CouchPotato::Config.database_name = 'test'
    expect(CouchPotato.full_url_to_database).to eq('http://127.0.0.1:5984/test')
  end

  it 'should return the set url' do
    CouchPotato::Config.database_name = 'http://db.local/test'
    expect(CouchPotato.full_url_to_database).to eq('http://db.local/test')
  end
end

describe CouchPotato, 'use' do
  it 'should return the db object' do
    db = CouchPotato.use('testdb')
    expect(db.couchrest_database.root.to_s).to eq('http://127.0.0.1:5984/testdb')
  end

  it 'returns a db from the additional_databases pool' do
    CouchPotato::Config.database_host = 'http://127.0.0.1:5984'
    CouchPotato::Config.additional_databases = { '1' => 'db1', '2' => 'db2' }

    db = CouchPotato.use('2')

    expect(db.couchrest_database.root.to_s).to eq('http://127.0.0.1:5984/db2')
  end
end

describe CouchPotato, '.models' do
  it 'returns all classes that have implemented CouchPotato::Persistence' do
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
