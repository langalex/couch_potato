require File.dirname(__FILE__) + '/../spec_helper'
require 'couch_potato/rspec'

class WithStubbedView
  include CouchPotato::Persistence
  
  view :stubbed_view, :key => :x
end

describe "stubbing the db" do
  it "should replace CouchPotato.database with a stub" do
    stub_db
    CouchPotato.database.should be_a(Spec::Mocks::Mock)
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
    WithStubbedView.stubbed_view('123').should be_a(Spec::Mocks::Mock)
  end
  
  it "should stub the database to return fake results when called with the stub" do
    @db.view(WithStubbedView.stubbed_view('123')).should == [:result]
  end
end