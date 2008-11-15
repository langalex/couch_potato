require File.dirname(__FILE__) + '/../spec_helper'

describe CouchPotato::Persistence::ExternalCollection, 'all' do
  before(:each) do
    @collection = CouchPotato::Persistence::ExternalCollection.new Comment, :commenter_id
    @collection.owner_id = 3
    @finder = stub 'finder'
    CouchPotato::Persistence::Finder.stub!(:new).and_return(@finder)
  end
  
  it "should delegate to a new finder" do
    @finder.should_receive(:find).with(Comment, {:commenter_id => 3}).and_return([])
    @collection.all
  end
  
  it "should search with the given conditions" do
    @finder.should_receive(:find).with(Comment, {:commenter_id => 3, :name => 'xyz'}, {}).and_return([])
    @collection.all :name => 'xyz'
  end
  
  it "should return the result of the finder" do
    result = stub('item', :_id => 1)
    @finder.stub!(:find).and_return([result])
    @collection.all.should == [result]
  end
end

describe CouchPotato::Persistence::ExternalCollection, 'count' do
  before(:each) do
    @collection = CouchPotato::Persistence::ExternalCollection.new Comment, :commenter_id
    @collection.owner_id = 3
    @finder = stub 'finder'
    CouchPotato::Persistence::Finder.stub!(:new).and_return(@finder)
  end
  
  it "should delegate to a new finder" do
    @finder.should_receive(:count).with(Comment, {:commenter_id => 3}, {})
    @collection.count
  end
  
  it "should count with the given conditions" do
    @finder.should_receive(:count).with(Comment, {:commenter_id => 3, :name => 'xyz'}, {})
    @collection.count :name => 'xyz'
  end
  
  it "should return the result of the finder" do
    @finder.stub!(:count).and_return(2)
    @collection.count.should == 2
  end
end

describe CouchPotato::Persistence::ExternalCollection, 'dirty?' do
  it "should return false if items haven't been loaded" do
    CouchPotato::Persistence::ExternalCollection.new(Comment, :commenter_id).should_not be_dirty
  end
  
  it "should return false if items haven't been touched" do
    CouchPotato::Persistence::Finder.stub!(:new).and_return(stub('finder', :find => [stub(:item, :dirty? => false, :_id => 1)]))
    collection = CouchPotato::Persistence::ExternalCollection.new(Comment, :commenter_id)
    collection.items
    collection.should_not be_dirty
  end
  
  it "should return true after adding a new item" do
    CouchPotato::Persistence::Finder.stub!(:new).and_return(stub('finder', :find => []))
    collection = CouchPotato::Persistence::ExternalCollection.new(Comment, :commenter_id)
    collection.items << stub(:item, :dirty? => false, :_id => 1)
    collection.should be_dirty
  end
  
  it "should return true after removing an item" do
    CouchPotato::Persistence::Finder.stub!(:new).and_return(stub('finder', :find => [stub(:item, :dirty? => false, :_id => 1)]))
    collection = CouchPotato::Persistence::ExternalCollection.new(Comment, :commenter_id)
    collection.items.pop
    collection.should be_dirty
  end
  
  it "should return true when an item is dirty" do
    CouchPotato::Persistence::Finder.stub!(:new).and_return(stub('finder', :find => [stub(:item, :dirty? => true, :_id => 1)]))
    collection = CouchPotato::Persistence::ExternalCollection.new(Comment, :commenter_id)
    collection.items
    collection.should be_dirty
  end
end