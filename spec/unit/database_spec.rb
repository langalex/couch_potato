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

describe CouchPotato::Database, 'new' do
  it "should raise an exception if the database doesn't exist" do
    lambda {
      CouchPotato::Database.new CouchRest.database('couch_potato_invalid')
    }.should raise_error('Database \'couch_potato_invalid\' does not exist.')
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
    CouchPotato.full_url_to_database.should == 'https://example.com/database'
  end

  it "should return the full URL when it starts with http" do
    CouchPotato::Config.database_name = "http://example.com/database"
    CouchPotato.full_url_to_database.should == 'http://example.com/database'
  end

  it "should use localhost when no protocol was specified" do
    CouchPotato::Config.database_name = "database"
    CouchPotato.full_url_to_database.should == 'http://127.0.0.1:5984/database'
  end
end

describe CouchPotato::Database, 'load' do
  
  let(:couchrest_db) { stub('couchrest db', :info => nil) }
  let(:db) { CouchPotato::Database.new couchrest_db }
  
  it "should raise an exception if nil given" do
    lambda {
      db.load nil
    }.should raise_error("Can't load a document without an id (got nil)")
  end

  it "should set itself on the model" do
    user = mock('user').as_null_object
    DbTestUser.stub!(:new).and_return(user)
    couchrest_db.stub(:get).and_return DbTestUser.json_create({JSON.create_id => 'DbTestUser'})
    user.should_receive(:database=).with(db)
    db.load '1'
  end

  it "should load namespaced models" do
    couchrest_db.stub(:get).and_return Parent::Child.json_create({JSON.create_id => 'Parent::Child'})
    db.load('1').class.should == Parent::Child
  end
  
  context "when several ids given" do
    
    let(:doc1) { DbTestUser.new }
    let(:doc2) { DbTestUser.new }
    let(:response) do
      {"rows" => [{}, {"doc" => doc1}, {"doc" => doc2}]}
    end
    
    before(:each) do
      couchrest_db.stub(:bulk_load).and_return response
    end

    it "requests the couchrest bulk method" do
      couchrest_db.should_receive(:bulk_load).with(['1', '2', '3'])
      db.load ['1', '2', '3']
    end

    it "returns only found documents" do
      db.load(['1', '2', '3']).should have(2).items
    end

    it "writes itself to each of the documents" do
      db.load(['1', '2', '3']).each do |doc|
        doc.database.should eql(db)
      end
    end
  end
end

describe CouchPotato::Database, 'load!' do
  
  let(:db) { CouchPotato::Database.new(stub('couchrest db', :info => nil)) }
  
  it "should raise an error if no document found" do
    db.couchrest_database.stub(:get).and_raise(RestClient::ResourceNotFound)
    lambda {
      db.load! '1'
    }.should raise_error(CouchPotato::NotFound)
  end
  
  context "when several ids given" do
    
    let(:docs) do
      [
        DbTestUser.new(:id => '1'),
        DbTestUser.new(:id => '2')
      ]
    end
    
    before(:each) do
      db.stub(:load).and_return(docs)
    end
    
    it "raises an exception when not all documents could be found" do
      lambda {
        db.load! ['1', '2', '3']
      }.should raise_error(CouchPotato::NotFound, ['3'])
    end
    
    it "raises no exception when all documents are found" do
      docs << DbTestUser.new(:id => '3')
      lambda {
        db.load! ['1', '2', '3']
      }.should_not raise_error(CouchPotato::NotFound)
    end
  end
end

describe CouchPotato::Database, 'save_document' do
  before(:each) do
    @db = CouchPotato::Database.new(stub('couchrest db').as_null_object)
  end

  it "should set itself on the model for a new object before doing anything else" do
    @db.stub(:valid_document?).and_return false
    user = stub('user', :new? => true).as_null_object
    user.should_receive(:database=).with(@db)
    @db.save_document user
  end

  class Category
    include CouchPotato::Persistence
    property :name
    validates_presence_of :name
  end

  it "should return false when creating a new document and the validations failed" do
    CouchPotato.database.save_document(Category.new).should == false
  end

  it "should return false when saving an existing document and the validations failed" do
    category = Category.new(:name => "pizza")
    CouchPotato.database.save_document(category).should == true
    category.name = nil
    CouchPotato.database.save_document(category).should == false
  end

  describe "when creating with validate options" do
    it "should not run the validations when saved with false" do
      category = Category.new
      @db.save_document(category, false)
      category.new?.should == false
    end

    it "should run the validations when saved with true" do
      category = Category.new
      @db.save_document(category, true)
      category.new?.should == true
    end

    it "should run the validations when saved with default" do
      category = Category.new
      @db.save_document(category)
      category.new?.should == true
    end
  end

  describe "when updating with validate options" do
    it "should not run the validations when saved with false" do
      category = Category.new(:name => 'food')
      @db.save_document(category)
      category.new?.should be_false
      category.name = nil
      @db.save_document(category, false)
      category.dirty?.should be_false
    end

    it "should run the validations when saved with true" do
      category = Category.new(:name => "food")
      @db.save_document(category)
      category.new?.should == false
      category.name = nil
      @db.save_document(category, true)
      category.dirty?.should == true
      category.valid?.should == false
    end

    it "should run the validations when saved with default" do
      category = Category.new(:name => "food")
      @db.save_document(category)
      category.new?.should == false
      category.name = nil
      @db.save_document(category)
      category.dirty?.should == true
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
      spock.errors[:validation].should == ['failed']
    end

    it "should keep errors added in before_validation_on_* callbacks when creating a new object" do
      spock = Vulcan.new(:name => 'spock')
      @db.save_document(spock, false)
      spock.new?.should == false
      spock.name = "spock's father"
      @db.save_document(spock)
      spock.errors[:validation].should == ['failed']
    end

    it "should keep errors generated from normal validations together with errors set in normal validations" do
      spock = Vulcan.new
      @db.save_document(spock)
      spock.errors[:validation].should == ['failed']
      spock.errors[:name].first.should =~ /can't be (empty|blank)/
    end

    it "should clear errors on subsequent, valid saves when creating" do
      spock = Vulcan.new
      @db.save_document(spock)

      spock.name = 'Spock'
      @db.save_document(spock)
      spock.errors[:name].should == []
    end

    it "should clear errors on subsequent, valid saves when updating" do
      spock = Vulcan.new(:name => 'spock')
      @db.save_document(spock, false)

      spock.name = nil
      @db.save_document(spock)
      spock.errors[:name].first.should =~ /can't be (empty|blank)/

      spock.name = 'Spock'
      @db.save_document(spock)
      spock.errors[:name].should == []
    end

  end
end

describe CouchPotato::Database, 'first' do
  before(:each) do
    @couchrest_db = stub('couchrest db').as_null_object
    @db = CouchPotato::Database.new(@couchrest_db)
    @result = stub('result')
    @spec = stub('view spec', :process_results => [@result]).as_null_object
    CouchPotato::View::ViewQuery.stub(:new => stub('view query', :query_view! => {'rows' => [@result]}))
  end

  it "should return the first result from a view query" do
    @db.first(@spec).should == @result
  end

  it "should return nil if there are no results" do
    @spec.stub(:process_results => [])
    @db.first(@spec).should be_nil
  end
end

describe CouchPotato::Database, 'first!' do
  before(:each) do
    @couchrest_db = stub('couchrest db').as_null_object
    @db = CouchPotato::Database.new(@couchrest_db)
    @result = stub('result')
    @spec = stub('view spec', :process_results => [@result]).as_null_object
    CouchPotato::View::ViewQuery.stub(:new => stub('view query', :query_view! => {'rows' => [@result]}))
  end

  it "returns the first result from a view query" do
    @db.first!(@spec).should == @result
  end

  it "raises an error if there are no results" do
    @spec.stub(:process_results => [])
    lambda {
      @db.first!(@spec)
    }.should raise_error(CouchPotato::NotFound)
  end
end

describe CouchPotato::Database, 'view' do
  before(:each) do
    @couchrest_db = stub('couchrest db').as_null_object
    @db = CouchPotato::Database.new(@couchrest_db)
    @result = stub('result')
    @spec = stub('view spec', :process_results => [@result]).as_null_object
    CouchPotato::View::ViewQuery.stub(:new => stub('view query', :query_view! => {'rows' => [@result]}))
  end

  it "initialzes a view query with map/reduce/list funtions" do
    @spec.stub(:design_document => 'design_doc', :view_name => 'my_view',
      :map_function => '<map_code>', :reduce_function => '<reduce_code>',
      :list_name => 'my_list', :list_function => '<list_code>', :language => 'javascript')
    CouchPotato::View::ViewQuery.should_receive(:new).with(
      @couchrest_db,
      'design_doc',
      {'my_view' => {
        :map => '<map_code>',
        :reduce => '<reduce_code>'
      }},
      {'my_list' => '<list_code>'},
      'javascript')
    @db.view(@spec)
  end

  it "initialzes a view query with only map/reduce functions" do
    @spec.stub(:design_document => 'design_doc', :view_name => 'my_view',
      :map_function => '<map_code>', :reduce_function => '<reduce_code>',
      :list_name => nil, :list_function => nil).as_null_object
    CouchPotato::View::ViewQuery.should_receive(:new).with(
      @couchrest_db,
      'design_doc',
      {'my_view' => {
        :map => '<map_code>',
        :reduce => '<reduce_code>'
      }}, nil, anything)
    @db.view(@spec)
  end

  it "sets itself on returned results that have an accessor" do
    @result.stub(:respond_to?).with(:database=).and_return(true)
    @result.should_receive(:database=).with(@db)
    @db.view(@spec)
  end

  it "does not set itself on returned results that don't have an accessor" do
    @result.stub(:respond_to?).with(:database=).and_return(false)
    @result.should_not_receive(:database=).with(@db)
    @db.view(@spec)
  end

  it "does not try to set itself on result sets that are not collections" do
    lambda {
      @spec.stub(:process_results => 1)
    }.should_not raise_error

    @db.view(@spec)
  end
end
