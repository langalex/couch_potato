require 'spec_helper'

class DbTestUser
  include CouchPotato::Persistence
end

# namespaced model
module Parent
  class Child
    include CouchPotato::Persistence
  end
end

describe CouchPotato::Database, 'full_url_to_database' do
  before(:all) do
    @database_url = CouchPotato::Config.database_name
  end

  after(:all) do
    CouchPotato::Config.database_name = @database_url
  end

  it "should return the full URL when it starts with https" do
    CouchPotato::Config.database_name = "https://example.com/database"
    expect(CouchPotato.full_url_to_database).to eq('https://example.com/database')
  end

  it "should return the full URL when it starts with http" do
    CouchPotato::Config.database_name = "http://example.com/database"
    expect(CouchPotato.full_url_to_database).to eq('http://example.com/database')
  end

  it "should use localhost when no protocol was specified" do
    CouchPotato::Config.database_name = "database"
    expect(CouchPotato.full_url_to_database).to eq('http://127.0.0.1:5984/database')
  end
end

describe CouchPotato::Database, 'load' do
  let(:couchrest_db) { double('couchrest db', :info => nil).as_null_object }
  let(:db) { CouchPotato::Database.new couchrest_db }

  it "should raise an exception if nil given" do
    expect {
      db.load nil
    }.to raise_error("Can't load a document without an id (got nil)")
  end

  it "should set itself on the model" do
    user = double('user').as_null_object
    allow(DbTestUser).to receive(:new).and_return(user)
    allow(couchrest_db).to receive(:get).and_return DbTestUser.json_create({JSON.create_id => 'DbTestUser'})
    expect(user).to receive(:database=).with(db)
    db.load '1'
  end

  it "should load namespaced models" do
    allow(couchrest_db).to receive(:get).and_return Parent::Child.json_create({JSON.create_id => 'Parent::Child'})
    expect(db.load('1').class).to eq(Parent::Child)
  end

  context "when several ids given" do
    let(:doc1) { DbTestUser.new }
    let(:doc2) { DbTestUser.new }
    let(:response) do
      {"rows" => [{'doc' => nil}, {"doc" => doc1}, {"doc" => doc2}]}
    end

    before(:each) do
      allow(couchrest_db).to receive(:bulk_load) { response }
    end

    it "requests the couchrest bulk method" do
      expect(couchrest_db).to receive(:bulk_load).with(['1', '2', '3'])
      db.load ['1', '2', '3']
    end

    it "returns only found documents" do
      expect(db.load(['1', '2', '3']).size).to eq(2)
    end

    it "writes itself to each of the documents" do
      db.load(['1', '2', '3']).each do |doc|
        expect(doc.database).to eql(db)
      end
    end

    it 'does not write itself to a document that has no database= method' do
      doc1 = double(:doc1)
      allow(doc1).to receive(:respond_to?).with(:database=) { false }
      allow(couchrest_db).to receive(:bulk_load) do
        {"rows" => [{'doc' => doc1}]}
      end

      expect(doc1).not_to receive(:database=)

      db.load(['1'])
    end
  end
end

describe CouchPotato::Database, 'load!' do

  let(:db) { CouchPotato::Database.new(double('couchrest db', :info => nil).as_null_object) }

  it "should raise an error if no document found" do
    allow(db.couchrest_database).to receive(:get).and_return(nil)
    expect {
      db.load! '1'
    }.to raise_error(CouchPotato::NotFound)
  end

  it 'returns the found document' do
    doc = double(:doc).as_null_object
    allow(db.couchrest_database).to receive(:get) {doc}
    expect(db.load!('1')).to eq(doc)
  end

  context "when several ids given" do

    let(:docs) do
      [
        DbTestUser.new(:id => '1'),
        DbTestUser.new(:id => '2')
      ]
    end

    before(:each) do
      allow(db).to receive(:load).and_return(docs)
    end

    it "raises an exception when not all documents could be found" do
      expect {
        db.load! ['1', '2', '3', '4']
      }.to raise_error(CouchPotato::NotFound, '3, 4')
    end

    it "raises no exception when all documents are found" do
      docs << DbTestUser.new(:id => '3')
      expect {
        db.load! ['1', '2', '3']
      }.not_to raise_error
    end
  end
end

describe CouchPotato::Database, 'save_document' do
  before(:each) do
    @db = CouchPotato::Database.new(double('couchrest db').as_null_object)
  end

  it "should set itself on the model for a new object before doing anything else" do
    allow(@db).to receive(:valid_document?).and_return false
    user = double('user', :new? => true).as_null_object
    expect(user).to receive(:database=).with(@db)
    @db.save_document user
  end

  class Category
    include CouchPotato::Persistence
    property :name
    validates_presence_of :name
  end

  it "should return false when creating a new document and the validations failed" do
    expect(CouchPotato.database.save_document(Category.new)).to eq(false)
  end

  it "should return false when saving an existing document and the validations failed" do
    category = Category.new(:name => "pizza")
    expect(CouchPotato.database.save_document(category)).to eq(true)
    category.name = nil
    expect(CouchPotato.database.save_document(category)).to eq(false)
  end

  describe "when creating with validate options" do
    it "should not run the validations when saved with false" do
      category = Category.new
      @db.save_document(category, false)
      expect(category.new?).to eq(false)
    end

    it "should run the validations when saved with true" do
      category = Category.new
      @db.save_document(category, true)
      expect(category.new?).to eq(true)
    end

    it "should run the validations when saved with default" do
      category = Category.new
      @db.save_document(category)
      expect(category.new?).to eq(true)
    end
  end

  describe "when updating with validate options" do
    it "should not run the validations when saved with false" do
      category = Category.new(:name => 'food')
      @db.save_document(category)
      expect(category.new?).to be_falsey
      category.name = nil
      @db.save_document(category, false)
      expect(category.changed?).to be_falsey
    end

    it "should run the validations when saved with true" do
      category = Category.new(:name => "food")
      @db.save_document(category)
      expect(category.new?).to eq(false)
      category.name = nil
      @db.save_document(category, true)
      expect(category.changed?).to eq(true)
      expect(category.valid?).to eq(false)
    end

    it "should run the validations when saved with default" do
      category = Category.new(:name => "food")
      @db.save_document(category)
      expect(category.new?).to eq(false)
      category.name = nil
      @db.save_document(category)
      expect(category.changed?).to eq(true)
    end
  end

  describe "when saving documents with errors set in callbacks" do
    class Vulcan
      include CouchPotato::Persistence
      before_validation_on_create :set_errors
      before_validation_on_update :set_errors

      property :name
      validates_presence_of :name

      def set_errors
        errors.add(:validation, "failed")
      end
    end

    it "should keep errors added in before_validation_on_* callbacks when creating a new object" do
      spock = Vulcan.new(:name => 'spock')
      @db.save_document(spock)
      expect(spock.errors[:validation]).to eq(['failed'])
    end

    it "should keep errors added in before_validation_on_* callbacks when creating a new object" do
      spock = Vulcan.new(:name => 'spock')
      @db.save_document(spock, false)
      expect(spock.new?).to eq(false)
      spock.name = "spock's father"
      @db.save_document(spock)
      expect(spock.errors[:validation]).to eq(['failed'])
    end

    it "should keep errors generated from normal validations together with errors set in normal validations" do
      spock = Vulcan.new
      @db.save_document(spock)
      expect(spock.errors[:validation]).to eq(['failed'])
      expect(spock.errors[:name].first).to match(/can't be (empty|blank)/)
    end

    it "should clear errors on subsequent, valid saves when creating" do
      spock = Vulcan.new
      @db.save_document(spock)

      spock.name = 'Spock'
      @db.save_document(spock)
      expect(spock.errors[:name]).to eq([])
    end

    it "should clear errors on subsequent, valid saves when updating" do
      spock = Vulcan.new(:name => 'spock')
      @db.save_document(spock, false)

      spock.name = nil
      @db.save_document(spock)
      expect(spock.errors[:name].first).to match(/can't be (empty|blank)/)

      spock.name = 'Spock'
      @db.save_document(spock)
      expect(spock.errors[:name]).to eq([])
    end

  end
end

describe CouchPotato::Database, 'first' do
  before(:each) do
    @couchrest_db = double('couchrest db').as_null_object
    @db = CouchPotato::Database.new(@couchrest_db)
    @result = double('result')
    @spec = double('view spec', :process_results => [@result]).as_null_object
    allow(CouchPotato::View::ViewQuery).to receive_messages(:new => double('view query', :query_view! => {'rows' => [@result]}))
  end

  it "should return the first result from a view query" do
    expect(@db.first(@spec)).to eq(@result)
  end

  it "should return nil if there are no results" do
    allow(@spec).to receive_messages(:process_results => [])
    expect(@db.first(@spec)).to be_nil
  end
end

describe CouchPotato::Database, 'first!' do
  before(:each) do
    @couchrest_db = double('couchrest db').as_null_object
    @db = CouchPotato::Database.new(@couchrest_db)
    @result = double('result')
    @spec = double('view spec', :process_results => [@result]).as_null_object
    allow(CouchPotato::View::ViewQuery).to receive_messages(:new => double('view query', :query_view! => {'rows' => [@result]}))
  end

  it "returns the first result from a view query" do
    expect(@db.first!(@spec)).to eq(@result)
  end

  it "raises an error if there are no results" do
    allow(@spec).to receive_messages(:process_results => [])
    expect {
      @db.first!(@spec)
    }.to raise_error(CouchPotato::NotFound)
  end
end

describe CouchPotato::Database, 'view' do
  before(:each) do
    @couchrest_db = double('couchrest db').as_null_object
    @db = CouchPotato::Database.new(@couchrest_db)
    @result = double('result')
    @spec = double('view spec', :process_results => [@result]).as_null_object
    allow(CouchPotato::View::ViewQuery).to receive_messages(:new => double('view query', :query_view! => {'rows' => [@result]}))
  end

  it "initialzes a view query with map/reduce/list/lib funtions" do
    allow(@spec).to receive_messages(:design_document => 'design_doc', :view_name => 'my_view',
      :map_function => '<map_code>', :reduce_function => '<reduce_code>',
      :lib => {:test => '<test_code>'},
      :list_name => 'my_list', :list_function => '<list_code>', :language => 'javascript')
    expect(CouchPotato::View::ViewQuery).to receive(:new).with(
      @couchrest_db,
      'design_doc',
      {'my_view' => {
        :map => '<map_code>',
        :reduce => '<reduce_code>'
      }},
      {'my_list' => '<list_code>'},
      {:test => '<test_code>'},
      'javascript')
    @db.view(@spec)
  end

  it "initialzes a view query with map/reduce/list funtions" do
    allow(@spec).to receive_messages(:design_document => 'design_doc', :view_name => 'my_view',
      :map_function => '<map_code>', :reduce_function => '<reduce_code>',
      :lib => nil, :list_name => 'my_list', :list_function => '<list_code>',
      :language => 'javascript')
    expect(CouchPotato::View::ViewQuery).to receive(:new).with(
      @couchrest_db,
      'design_doc',
      {'my_view' => {
        :map => '<map_code>',
        :reduce => '<reduce_code>'
      }},
      {'my_list' => '<list_code>'},
      nil,
      'javascript')
    @db.view(@spec)
  end

  it "initialzes a view query with only map/reduce/lib functions" do
    allow(@spec).to receive_messages(:design_document => 'design_doc', :view_name => 'my_view',
      :map_function => '<map_code>', :reduce_function => '<reduce_code>',
      :list_name => nil, :list_function => nil,
      :lib => {:test => '<test_code>'})
    expect(CouchPotato::View::ViewQuery).to receive(:new).with(
      @couchrest_db,
      'design_doc',
      {'my_view' => {
        :map => '<map_code>',
        :reduce => '<reduce_code>'
      }}, nil, {:test => '<test_code>'}, anything)
    @db.view(@spec)
  end

  it "initialzes a view query with only map/reduce functions" do
    allow(@spec).to receive_messages(:design_document => 'design_doc', :view_name => 'my_view',
      :map_function => '<map_code>', :reduce_function => '<reduce_code>',
      :lib => nil, :list_name => nil, :list_function => nil)
    expect(CouchPotato::View::ViewQuery).to receive(:new).with(
      @couchrest_db,
      'design_doc',
      {'my_view' => {
        :map => '<map_code>',
        :reduce => '<reduce_code>'
      }}, nil, nil, anything)
    @db.view(@spec)
  end

  it "sets itself on returned results that have an accessor" do
    allow(@result).to receive(:respond_to?).with(:database=).and_return(true)
    expect(@result).to receive(:database=).with(@db)
    @db.view(@spec)
  end

  it "does not set itself on returned results that don't have an accessor" do
    allow(@result).to receive(:respond_to?).with(:database=).and_return(false)
    expect(@result).not_to receive(:database=).with(@db)
    @db.view(@spec)
  end

  it "does not try to set itself on result sets that are not collections" do
    expect {
      allow(@spec).to receive_messages(:process_results => 1)
    }.not_to raise_error

    @db.view(@spec)
  end
end

describe CouchPotato::Database, '#destroy' do
  it 'does not try to delete an already deleted document' do
    couchrest_db = double(:couchrest_db)
    allow(couchrest_db).to receive(:delete_doc).and_raise(CouchRest::Conflict)
    db = CouchPotato::Database.new couchrest_db
    document = double(:document, reload: nil).as_null_object
    allow(document).to receive(:run_callbacks).and_yield

    expect {
      db.destroy document
    }.to_not raise_error
  end
end

describe CouchPotato::Database, '#switch_to' do
  let(:couchrest_db) { instance_double(CouchRest::Database) }
  let(:db) { CouchPotato::Database.new couchrest_db }

  it 'returns the database with the given name' do
    new_db = db.switch_to('db2')

    expect(new_db.couchrest_database.name).to eq('db2')
  end

  it 'adds a cleared cache to the new database if the original has one' do
    db.cache = {key: 'value'}
    new_db = db.switch_to('db2')

    expect(new_db.cache).to be_empty
  end

  it 'does not clear the cache of the original database' do
    db.cache = {key: 'value'}
    _new_db = db.switch_to('db2')

    expect(db.cache).to have_key(:key)
  end

  it 'adds no cache to the new database if the original has none' do
    new_db = db.switch_to('db2')

    expect(new_db.cache).to be_nil
  end
end

describe CouchPotato::Database, '#switch_to_default' do
  let(:couchrest_db) { instance_double(CouchRest::Database) }
  let(:db) { CouchPotato::Database.new couchrest_db }

  it 'returns the default database' do
    new_db = db.switch_to_default

    expect(new_db.couchrest_database.name).to eq('couch_potato_test')
  end

  it 'adds a cleared cache to the new database if the original has one' do
    db.cache = {key: 'value'}
    new_db = db.switch_to_default

    expect(new_db.cache).to be_empty
  end

  it 'does not clear the cache of the original database' do
    db.cache = {key: 'value'}
    _new_db = db.switch_to_default

    expect(db.cache).to have_key(:key)
  end

  it 'adds no cache to the new database if the original has none' do
    new_db = db.switch_to_default

    expect(new_db.cache).to be_nil
  end
end