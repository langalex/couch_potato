require File.dirname(__FILE__) + '/spec_helper'

class Build
  include CouchPotato::Persistence
  
  property :state
  property :time
  
  view :timeline, :key => :time
  view :minimal_timeline, :key => :time, :properties => [:state]
  view :key_array_timeline, :key => [:time, :state]
  view :custom_timeline, :map => "function(doc) { emit(doc._id, {state: 'custom_' + doc.state}); }"
  view :custom_timeline_returns_docs, :map => "function(doc) { emit(doc._id, null); }", :include_docs => true
  
end

describe 'view' do
  before(:each) do
    recreate_db
  end
  
  it "should return instances of the class" do
    CouchPotato.database.save_document Build.new(:state => 'success', :time => '2008-01-01')
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
      CouchPotato.couchrest_database.save_doc({:state => 'success', :time => '2008-01-01'})
      Build.minimal_timeline.first.state.should == 'success'
    end
    
    it "should not assign the properties not configured" do
      CouchPotato.couchrest_database.save_doc({:state => 'success', :time => '2008-01-01'})
      Build.minimal_timeline.first.time.should be_nil
    end
    
    it "should assign the id even if it is not configured" do
      id = CouchPotato.couchrest_database.save_doc({:state => 'success', :time => '2008-01-01'})['id']
      Build.minimal_timeline.first._id.should == id
    end
  end
  
  describe "no properties defined" do
    it "should assign all properties to the objects by default" do
      id = CouchPotato.couchrest_database.save_doc({:state => 'success', :time => '2008-01-01'})['id']
      result = Build.timeline.first
      result.state.should == 'success'
      result.time.should == '2008-01-01'
      result._id.should == id
    end
  end
  
  describe "map function given" do
    it "should still return instances of the class" do
      CouchPotato.couchrest_database.save_doc({:state => 'success', :time => '2008-01-01'})
      Build.custom_timeline.map(&:class).should == [Build]
    end
    
    it "should assign the properties from the value" do
      CouchPotato.couchrest_database.save_doc({:state => 'success', :time => '2008-01-01'})
      Build.custom_timeline.map(&:state).should == ['custom_success']
    end
    
    it "should leave the other properties blank" do
      CouchPotato.couchrest_database.save_doc({:state => 'success', :time => '2008-01-01'})
      Build.custom_timeline.map(&:time).should == [nil]
    end
    
    describe "that returns null documents" do
      it "should return instances of the class" do
        CouchPotato.couchrest_database.save_doc({:state => 'success', :time => '2008-01-01'})
        Build.custom_timeline_returns_docs.map(&:class).should == [Build]
      end
      
      it "should assign the properties from the value" do
        CouchPotato.couchrest_database.save_doc({:state => 'success', :time => '2008-01-01'})
        Build.custom_timeline_returns_docs.map(&:state).should == ['success']
      end
    end
  end
  
  describe "with array as key" do
    it "should create a map function with the composite key" do
      CouchPotato::Persistence::ViewQuery.should_receive(:new).with(anything, anything, string_matching(/emit\(\[doc\['time'\], doc\['state'\]\]/)).and_return(stub('view query').as_null_object)
      Build.key_array_timeline
    end
  end
  
end