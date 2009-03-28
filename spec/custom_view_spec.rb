require File.dirname(__FILE__) + '/spec_helper'

class Build
  include CouchPotato::Persistence
  
  property :state
  property :time
  
  view :timeline, :key => :time
  view :minimal_timeline, :key => :time, :properties => [:state]
  view :custom_timeline, :map => "function(doc) { emit(doc._id, {state: 'custom_' + doc.state}); }"
  
end

describe 'view' do
  before(:each) do
    recreate_db
  end
  
  it "should return instances of the class" do
    Build.db.save_doc({:state => 'success', :time => '2008-01-01'})
    Build.timeline.map(&:class).should == [Build]
  end
  
  it "should pass the view options to the viw query" do
    query = mock 'query'
    CouchPotato::Persistence::ViewQuery.stub!(:new).and_return(query)
    query.should_receive(:query_view!).with(hash_including(:key => 1)).and_return('rows' => [])
    Build.timeline :key => 1
  end
  
  describe "properties defined" do
    it "should assign the configured properties" do
      Build.db.save_doc({:state => 'success', :time => '2008-01-01'})
      Build.minimal_timeline.first.state.should == 'success'
    end
    
    it "should not assign the properties not configured" do
      Build.db.save_doc({:state => 'success', :time => '2008-01-01'})
      Build.minimal_timeline.first.time.should be_nil
    end
    
    it "should assign the id even if it is not configured" do
      id = Build.db.save_doc({:state => 'success', :time => '2008-01-01'})['id']
      Build.minimal_timeline.first._id.should == id
    end
  end
  
  describe "no properties defined" do
    it "should assign all properties to the objects by default" do
      Build.db.save_doc({:state => 'success', :time => '2008-01-01'})
      Build.timeline.first.state.should == 'success'
      Build.timeline.first.time.should == '2008-01-01'
    end
  end
  
  describe "map function given" do
    it "should still return instances of the class" do
      Build.db.save_doc({:state => 'success', :time => '2008-01-01'})
      Build.custom_timeline.map(&:class).should == [Build]
    end
    
    it "should assign the properties from the value" do
      Build.db.save_doc({:state => 'success', :time => '2008-01-01'})
      Build.custom_timeline.map(&:state).should == ['custom_success']
    end
    
    it "should leave the other properties blank" do
      Build.db.save_doc({:state => 'success', :time => '2008-01-01'})
      Build.custom_timeline.map(&:time).should == [nil]
    end
  end
  
end