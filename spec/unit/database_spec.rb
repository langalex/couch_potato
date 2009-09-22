require File.dirname(__FILE__) + '/../spec_helper'

class DbTestUser
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

describe CouchPotato::Database, 'load' do
  it "should raise an exception if nil given" do
    db = CouchPotato::Database.new(stub('couchrest db', :info => nil))
    lambda {
      db.load nil
    }.should raise_error("Can't load a document without an id (got nil)")
  end

  it "should set itself on the model" do
    user = mock 'user'
    DbTestUser.stub!(:new).and_return(user)
    db = CouchPotato::Database.new(stub('couchrest db', :info => nil, :get => {'ruby_class' => 'DbTestUser'}))
    user.should_receive(:database=).with(db)
    db.load '1'
  end

  it "should load namespaced models" do
    db = CouchPotato::Database.new(stub('couchrest db', :info => nil, :get => {'ruby_class' => 'Parent::Child'}))
    db.load('1').class.should == Parent::Child
  end
end

describe CouchPotato::Database, 'save_document' do
  it "should set itself on the model for a new object before doing anything else" do
    db = CouchPotato::Database.new(stub('couchrest db', :info => nil))
    user = stub('user', :new? => true, :valid? => false).as_null_object
    user.should_receive(:database=).with(db)
    db.save_document user
  end
  
  class Category
    include CouchPotato::Persistence
    property :name
    validates_presence_of :name
  end
  
  describe "when creating with validate options" do
    it "should not run the validations when saved with false" do
      category = Category.new
      CouchPotato.database.save_document(category, false)
      category.new?.should == false
    end

    it "should not run the validations when saved with true" do
      category = Category.new
      CouchPotato.database.save_document(category, true)
      category.new?.should == true
    end

    it "should run the validations when saved with default" do
      category = Category.new
      CouchPotato.database.save_document(category)
      category.new?.should == true
    end
  end

  describe "when updating with validate options" do
    it "should not run the validations when saved with false" do
      category = Category.new(:name => 'food')
      CouchPotato.database.save_document(category)
      category.new?.should == false
      category.name = nil
      CouchPotato.database.save_document(category, false)
      category.dirty?.should == false
    end

    it "should run the validations when saved with true" do
      category = Category.new(:name => "food")
      CouchPotato.database.save_document(category)
      category.new?.should == false
      category.name = nil
      CouchPotato.database.save_document(category, true)
      category.dirty?.should == true
      category.valid?.should == false
    end

    it "should run the validations when saved with default" do
      category = Category.new(:name => "food")
      CouchPotato.database.save_document(category)
      category.new?.should == false
      category.name = nil
      CouchPotato.database.save_document(category)
      category.dirty?.should == true
    end
  end
end
