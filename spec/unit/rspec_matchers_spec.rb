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

  it "should work with date emit values" do
    spec = stub(:map_function => "function(doc) { emit(null, new Date(1368802800000)); }")
    spec.should map({}).to([nil, "2013-05-17T15:00:00.000Z"])
  end

  it "should work with commonJS modules" do
    spec = stub(
      :map_function => "function(doc) { var test = require('views/lib/test'); emit(null, test.test); }",
      :lib => {:test => "exports.test = 'test';"}
    )
    spec.should map({}).to([nil, "test"])
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

  it "should work with date return values" do
    spec = stub(:reduce_function => "function() { return new Date(1368802800000); }")
    spec.should reduce([], []).to("2013-05-17T15:00:00.000Z")
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

describe CouchPotato::RSpec::MapReduceToMatcher do
  before(:each) do
    @view_spec = stub(
      :map_function => "function(doc) {
          for (var i in doc.numbers)
            emit([doc.age, doc.name], doc.numbers[i]);
        }",
      :reduce_function => "function (keys, values, rereduce) {
          return Math.max.apply(this, values);
        }"
    )
    @docs = [
      {:name => "a", :age => 25, :numbers => [1, 2]},
      {:name => "b", :age => 25, :numbers => [3, 4]},
      {:name => "c", :age => 26, :numbers => [5, 6]},
      {:name => "d", :age => 27, :numbers => [7, 8]}]
  end

  it "should handle date return values" do
    spec = stub(:map_function => "function() { emit(null, null); }",
      :reduce_function => "function() { return new Date(1368802800000); }")
    spec.should map_reduce({}).to({"key" => nil, "value" => "2013-05-17T15:00:00.000Z"})
  end

  it "should handle date return values" do
    spec = stub(
      :map_function => "function() { var test = require('views/lib/test'); emit(null, test.test); }",
      :reduce_function => "function(keys, values) { return 'test' }",
      :lib => {:test => "exports.test = 'test'"})
    spec.should map_reduce({}).to({"key" => nil, "value" => "test"})
  end

  it "should handle sum function" do
    spec = stub(
      :map_function => "function(doc) { emit(null, doc.age); }",
      :reduce_function => "function(keys, values) { return sum(values); }")
    spec.should map_reduce(@docs).to({"key" => nil, "value" => 103})
  end

  context "without grouping" do
    it "should not group by key by default" do
      @view_spec.should map_reduce(@docs).to({"key" => nil, "value" => 8})
    end

    it "should group by key with :group => false" do
      @view_spec.should map_reduce(@docs).with_options(:group => false).to({"key" => nil, "value" => 8})
    end
  end

  context "with grouping" do
    [true, "exact"].each do |group_value|
      it "should group by the full key with option :group => #{group_value}" do
        @view_spec.should map_reduce(@docs).with_options(:group => group_value).to(
          {"key" => [25, "a"], "value" => 2},
          {"key" => [25, "b"], "value" => 4},
          {"key" => [26, "c"], "value" => 6},
          {"key" => [27, "d"], "value" => 8})
      end
    end

    it "should group by parts of the keys based on the :group_level option" do
      @view_spec.should map_reduce(@docs).with_options(:group_level => 1).to(
        {"key" => [25], "value" => 4},
        {"key" => [26], "value" => 6},
        {"key" => [27], "value" => 8})
    end
  end

  describe "rereducing" do
    before :each do
      @view_spec = stub(:map_function => "function(doc) {
          emit(doc.name, doc.number);
        }",
        :reduce_function => "function (keys, values, rereduce) {
          if (rereduce) {
            var result = {rereduce_values: []};
            for (var v in values) {
              result.rereduce_values.push(values[v].reduce_values);
            }
            return result;
          }
          return {reduce_values: values};
        }")
    end

    it "should reduce and rereduce for a single emit" do
      @view_spec.should map_reduce({:name => "a", :number => 1}).to({"key" => nil, "value" => {"rereduce_values" => [[1]]}})
    end

    it "should split and reduce each half of emitted values separately and rereduce the results" do
      docs = [
        {:name => "a", :number => 1},
        {:name => "a", :number => 2},
        {:name => "a", :number => 3},
        {:name => "a", :number => 4}]
      @view_spec.should map_reduce(docs).to({"key" => nil, "value" => {"rereduce_values" => [[1, 2], [3, 4]]}})
    end

    it "should correctly split and rereduce with an odd number of emits" do
      docs = [
        {:name => "a", :number => 1},
        {:name => "a", :number => 2},
        {:name => "a", :number => 3}]
      @view_spec.should map_reduce(docs).to({"key" => nil, "value" => {"rereduce_values" => [[1], [2, 3]]}})
    end
  end

  describe "failing specs" do
    it "should have a nice error message for failing should" do
      lambda {
        @view_spec.should map_reduce(@docs).with_options(:group => false).to({"key" => nil, "value" => 9})
      }.should raise_error('Expected to map/reduce to [{"key"=>nil, "value"=>9}] but got [{"key"=>nil, "value"=>8}].')
    end

    it "should have a nice error message for failing should not" do
      lambda {
        @view_spec.should_not map_reduce(@docs).with_options(:group => false).to({"key" => nil, "value" => 8})
      }.should raise_error('Expected not to map/reduce to [{"key"=>nil, "value"=>8}] but did.')
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

  it "should work with date values" do
    spec = stub(:list_function => "function() { send(JSON.stringify([{date: new Date(1368802800000)}])); }")
    spec.should list({"rows" => [{}]}).as([{"date" => "2013-05-17T15:00:00.000Z"}])
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

class HavePropertyMatcherTest
  include CouchPotato::Persistence

  property :foo, type: :boolean
  property :bar, default: "hello world"
end

describe CouchPotato::RSpec::HavePropertyMatcher do
  subject { HavePropertyMatcherTest }

  it "accepts an existing property" do
    expect(subject).to have_property(:foo)
  end

  it "rejects a nonexisting property" do
    expect(subject).not_to have_property(:faz)
  end

  it "should have a nice error message" do
    lambda {
      expect(subject).to have_property(:baz)
    }.should raise_error("Expected HavePropertyMatcherTest to have a property named `baz'")
  end

  it "should have a helpful error message" do
    lambda {
      expect(subject).to have_property(:foo).of_type(:fixnum)
    }.should raise_error("Expected HavePropertyMatcherTest to have a property " +
      "named `foo' of type fixnum (HavePropertyMatcherTest has a property " +
      "named `foo' of type boolean, not fixnum)")
  end

  describe "#of_type" do
    it "accepts a property of the correct data type" do
      expect(subject).to have_property(:foo).of_type(:boolean)
    end

    it "rejects a property of the incorrect data type" do
      expect(subject).not_to have_property(:foo).of_type(:fixnum)
    end
  end

  context "#with_options" do
    describe "default" do
      it "accepts a property with the correct default" do
        expect(subject).to have_property(:bar).with_options(default: "hello world")
      end

      it "rejects a property with an incorrect default" do
        expect(subject).not_to have_property(:bar).with_options(default: 123)
      end
    end
  end

end
