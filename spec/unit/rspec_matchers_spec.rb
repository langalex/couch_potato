require 'spec_helper'
require 'couch_potato/rspec'

describe CouchPotato::RSpec::MapToMatcher do
  
  describe "basic map function" do
    before(:each) do
      @view_spec = stub(:map_function => "function(doc) {emit(doc.name, doc.tags.length);}")
    end

    it "should pass if the given function emits the expected javascript" do
      @view_spec.should map({:name => 'horst', :tags => ['person', 'male']}).to(['horst', 2])
    end

    it "should not pass if the given function emits different javascript" do
      @view_spec.should_not map({:name => 'horst', :tags => ['person', 'male']}).to(['horst', 3])
    end
  end
  
  describe "functions emitting multiple times" do
    before(:each) do
      @view_spec = stub(:map_function => "function(doc) {emit(doc.name, doc.tags.length); emit(doc.tags[0], doc.tags[1])};")
    end
    
    it "should pass if the given function emits the expected javascript" do
      @view_spec.should map({:name => 'horst', :tags => ['person', 'male']}).to(['horst', 2], ['person', 'male'])
    end
  
    it "should return false if the given function emits different javascript" do
      @view_spec.should_not map({:name => 'horst', :tags => ['person', 'male']}).to(['horst', 2], ['male', 'person'])
    end
  end
  
  describe "failing specs" do
    before(:each) do
      @view_spec = stub(:map_function => "function(doc) {emit(doc.name, null)}")
    end
    
    it "should have a nice error message for failing should" do
      lambda {
        @view_spec.should map({:name => 'bill'}).to(['linus', nil])
      }.should raise_error('Expected to map to [["linus", nil]] but got [["bill", nil]].')
    end
    
    it "should have a nice error message for failing should not" do
      lambda {
        @view_spec.should_not map({:name => 'bill'}).to(['bill', nil])
      }.should raise_error('Expected not to map to [["bill", nil]] but did.')
    end
  end
end

describe CouchPotato::RSpec::ReduceToMatcher do
  before(:each) do
    @view_spec = stub(:reduce_function => "function(keys, values, rereduce) {
      if(rereduce) {
        return(sum(values) * 2);
      } else {
        return(sum(values));
      };
    }")
  end
  
  it "should pass if the given function return the expected javascript" do
    @view_spec.should reduce([], [1, 2, 3]).to(6)
  end
  
  it "should not pass if the given function returns different javascript" do
    @view_spec.should_not reduce([], [1, 2, 3]).to(7)
  end
  
  describe "rereduce" do
    it "should pass if the given function return the expected javascript" do
      @view_spec.should rereduce([], [1, 2, 3]).to(12)
    end
    
    it "should not pass if the given function returns different javascript" do
      @view_spec.should_not rereduce([], [1, 2, 3]).to(13)
    end
  end
  
  describe 'failing specs' do
    
    it "should have a nice error message for failing should" do
      lambda {
        @view_spec.should reduce([], [1, 2, 3]).to(7)
      }.should raise_error('Expected to reduce to 7 but got 6.')
    end
    
    it "should have a nice error message for failing should not" do
      lambda {
        @view_spec.should_not reduce([], [1, 2, 3]).to(6)
      }.should raise_error('Expected not to reduce to 6 but did.')
    end
  end
end

describe CouchPotato::RSpec::ListAsMatcher do
  before(:each) do
    @view_spec = stub(:list_function => "function() {var row = getRow(); send(JSON.stringify([{text: row.text + ' world'}]));}")
  end
  
  it "should pass if the function return the expected json" do
    @view_spec.should list({'rows' => [{:text => 'hello'}]}).as([{'text' => 'hello world'}])
  end
  
  it "should not pass if the function does not return the expected json" do
    @view_spec.should_not list({'rows' => [{:text => 'hello'}]}).as([{'text' => 'hello there'}])
  end
  
  describe "failing specs" do
    it "should have a nice error message for failing should" do
      lambda {
        @view_spec.should list({'rows' => [{:text => 'hello'}]}).as([{'text' => 'hello there'}])
      }.should raise_error('Expected to list as [{"text"=>"hello there"}] but got [{"text"=>"hello world"}].')
    end
    
    it "should have a nice error message for failing should not" do
      lambda {
        @view_spec.should_not list({'rows' => [{:text => 'hello'}]}).as([{'text' => 'hello world'}])
      }.should raise_error('Expected to not list as [{"text"=>"hello world"}] but did.')
    end
  end
end
