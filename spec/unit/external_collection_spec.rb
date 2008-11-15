require File.dirname(__FILE__) + '/../spec_helper'

describe CouchPotato::Persistence::ExternalCollection, 'all' do
  before(:each) do
    @collection = CouchPotato::Persistence::ExternalCollection.new Comment, :commenter_id
    @collection.owner_id = 3
    @finder = stub 'finder'
    CouchPotato::Persistence::Finder.stub!(:new).and_return(@finder)
  end
  
  it "should delegate to a new finder" do
    @finder.should_receive(:find).with(Comment, {:commenter_id => 3})
    @collection.all
  end
  
  it "should search with the given conditions" do
    @finder.should_receive(:find).with(Comment, {:commenter_id => 3, :name => 'xyz'}, {})
    @collection.all :name => 'xyz'
  end
  
  it "should return the result of the finder" do
    @finder.stub!(:find).and_return(:results)
    @collection.all.should == :results
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
