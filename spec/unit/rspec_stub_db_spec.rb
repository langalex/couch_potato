require 'spec_helper'
require 'couch_potato/rspec'

class WithStubbedView
  include CouchPotato::Persistence
  
  view :stubbed_view, :key => :x
end

describe "stubbing the db" do
  it "should replace CouchPotato.database with a stub" do
    stub_db
    CouchPotato.database.should be_a(RSpec::Mocks::Mock)
  end
  
  it "should return the stub" do
    db = stub_db
    CouchPotato.database.should == db
  end
end

describe "stubbing a view" do
  before(:each) do
    @db = stub_db
    @db.stub_view(WithStubbedView, :stubbed_view).with('123').and_return([:result])
  end
  
  it "should stub the view to return a stub" do
    WithStubbedView.stubbed_view('123').should be_a(RSpec::Mocks::Mock)
  end
  
  it "should stub the database to return fake results when called with the stub" do
    @db.view(WithStubbedView.stubbed_view('123')).should == [:result]
  end
  
  it "stubs the database to return the first fake result" do
    @db.first(WithStubbedView.stubbed_view('123')).should == :result
    @db.first!(WithStubbedView.stubbed_view('123')).should == :result
  end
  
  it "skips stubbing the first view (i.e. doesn't crash) if the fake result does not respond to first" do
    @db.stub_view(WithStubbedView, :stubbed_view).with('123').and_return(:results)
    
    @db.view(WithStubbedView.stubbed_view('123')).should == :results
  end
  
  it "supports the block style return syntax with `with`" do
    @db.stub_view(WithStubbedView, :stubbed_view).with('123') {:results}
    
    @db.view(WithStubbedView.stubbed_view('123')).should == :results
  end
  
  it "supports the block style return syntax without `with`" do
    @db.stub_view(WithStubbedView, :stubbed_view) {:results}
    
    @db.view(WithStubbedView.stubbed_view('123')).should == :results
  end
  
end