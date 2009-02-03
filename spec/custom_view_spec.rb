require File.dirname(__FILE__) + '/spec_helper'

class Build
  include CouchPotato::Persistence
  
  property :state
  property :time
  
  view :timeline, :key => :time
  view :minimal_timeline, :key => :time, :properties => [:state]
end

describe 'custom view' do
  before(:each) do
    CouchPotato::Persistence.Db.delete!
    CouchPotato::Persistence.Db!
  end
  
  it "should return instances of the class" do
    Build.db.save({:state => 'success', :time => '2008-01-01'})
    Build.timeline.map(&:class).should == [Build]
  end
  
  it "should assign all properties to the objects by default" do
    Build.db.save({:state => 'success', :time => '2008-01-01'})
    Build.timeline.first.state.should == 'success'
    Build.timeline.first.time.should == '2008-01-01'
  end
  
  it "should assign the configured properties" do
    Build.db.save({:state => 'success', :time => '2008-01-01'})
    Build.minimal_timeline.first.state.should == 'success'
  end
  
  it "should assign the id when properties are configured" do
    id = Build.db.save({:state => 'success', :time => '2008-01-01'})['id']
    Build.minimal_timeline.first._id.should == id
  end
  
  it "should not assign the properties not configured" do
    Build.db.save({:state => 'success', :time => '2008-01-01'})
    Build.minimal_timeline.first.time.should be_nil
  end
end