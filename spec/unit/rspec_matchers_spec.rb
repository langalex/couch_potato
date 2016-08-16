require 'spec_helper'
require 'couch_potato-rspec'

describe CouchPotato::RSpec::MapToMatcher do

  describe "basic map function" do
    before(:each) do
      @view_spec = double(:map_function => "function(doc) {emit(doc.name, doc.tags.length);}")
    end

    it "should pass if the given function emits the expected javascript" do
      expect(@view_spec).to map({:name => 'horst', :tags => ['person', 'male']}).to(['horst', 2])
    end

    it "should not pass if the given function emits different javascript" do
      expect(@view_spec).not_to map({:name => 'horst', :tags => ['person', 'male']}).to(['horst', 3])
    end
  end

  describe "functions emitting multiple times" do
    before(:each) do
      @view_spec = double(:map_function => "function(doc) {emit(doc.name, doc.tags.length); emit(doc.tags[0], doc.tags[1])};")
    end

    it "should pass if the given function emits the expected javascript" do
      expect(@view_spec).to map({:name => 'horst', :tags => ['person', 'male']}).to(['horst', 2], ['person', 'male'])
    end

    it "should return false if the given function emits different javascript" do
      expect(@view_spec).not_to map({:name => 'horst', :tags => ['person', 'male']}).to(['horst', 2], ['male', 'person'])
    end
  end

  it "should work with date emit values" do
    spec = double(:map_function => "function(doc) { emit(null, new Date(1368802800000)); }")
    expect(spec).to map({}).to([nil, "2013-05-17T15:00:00.000Z"])
  end

  it "should work with commonJS modules that use 'exports'" do
    spec = double(
      :map_function => "function(doc) { var test = require('views/lib/test'); emit(null, test.test); }",
      :lib => {:test => "exports.test = 'test';"}
    )
    expect(spec).to map({}).to([nil, "test"])
  end

  it "should work with commonJS modules that use 'module.exports'" do
    spec = double(
      :map_function => "function(doc) { var test = require('views/lib/test'); emit(null, test.test); }",
      :lib => {:test => "module.exports.test = 'test';"}
    )
    expect(spec).to map({}).to([nil, "test"])
  end

  describe "failing specs" do
    before(:each) do
      @view_spec = double(:map_function => "function(doc) {emit(doc.name, null)}")
    end

    it "should have a nice error message for failing should" do
      expect {
        expect(@view_spec).to map({:name => 'bill'}).to(['linus', nil])
      }.to raise_error('Expected to map to [["linus", nil]] but got [["bill", nil]].')
    end

    it "should have a nice error message for failing should not" do
      expect {
        expect(@view_spec).not_to map({:name => 'bill'}).to(['bill', nil])
      }.to raise_error('Expected not to map to [["bill", nil]] but did.')
    end
  end
end

describe CouchPotato::RSpec::ReduceToMatcher do
  before(:each) do
    @view_spec = double(:reduce_function => "function(keys, values, rereduce) {
      if(rereduce) {
        return(sum(values) * 2);
      } else {
        return(sum(values));
      };
    }")
  end

  it "should pass if the given function return the expected javascript" do
    expect(@view_spec).to reduce([], [1, 2, 3]).to(6)
  end

  it "should not pass if the given function returns different javascript" do
    expect(@view_spec).not_to reduce([], [1, 2, 3]).to(7)
  end

  it "should work with date return values" do
    spec = double(:reduce_function => "function() { return new Date(1368802800000); }")
    expect(spec).to reduce([], []).to("2013-05-17T15:00:00.000Z")
  end

  describe "rereduce" do
    it "should pass if the given function return the expected javascript" do
      expect(@view_spec).to rereduce([], [1, 2, 3]).to(12)
    end

    it "should not pass if the given function returns different javascript" do
      expect(@view_spec).not_to rereduce([], [1, 2, 3]).to(13)
    end
  end

  describe 'failing specs' do

    it "should have a nice error message for failing should" do
      expect {
        expect(@view_spec).to reduce([], [1, 2, 3]).to(7)
      }.to raise_error('Expected to reduce to 7 but got 6.')
    end

    it "should have a nice error message for failing should not" do
      expect {
        expect(@view_spec).not_to reduce([], [1, 2, 3]).to(6)
      }.to raise_error('Expected not to reduce to 6 but did.')
    end
  end
end

describe CouchPotato::RSpec::MapReduceToMatcher do
  before(:each) do
    @view_spec = double(
      :map_function => "function(doc) {
          for (var i in doc.numbers)
            emit([doc.age, doc.name], doc.numbers[i]);
        }",
      :reduce_function => "function (keys, values, rereduce) {
          return Math.max.apply(this, values);
        }"
    )
    @docs = [
      {:age => 25, :name => "a", :numbers => [1, 2]},
      {:age => 25, :name => "b", :numbers => [3, 4]},
      {:age => 26, :name => "c", :numbers => [5, 6]},
      {:age => 27, :name => "d", :numbers => [7, 8]}]
  end

  it "should handle date return values" do
    spec = double(:map_function => "function() { emit(null, null); }",
      :reduce_function => "function() { return new Date(1368802800000); }")
    expect(spec).to map_reduce({}).to({"key" => nil, "value" => "2013-05-17T15:00:00.000Z"})
  end

  it "should handle CommonJS requires for modules that use 'exports'" do
    spec = double(
      :map_function => "function() { var test = require('views/lib/test'); emit(null, test.test); }",
      :reduce_function => "function(keys, values) { return 'test' }",
      :lib => {:test => "exports.test = 'test'"})
    expect(spec).to map_reduce({}).to({"key" => nil, "value" => "test"})
  end

  it "should handle CommonJS requires for modules that use 'module.exports'" do
    spec = double(
      :map_function => "function() { var test = require('views/lib/test'); emit(null, test.test); }",
      :reduce_function => "function(keys, values) { return 'test' }",
      :lib => {:test => "module.exports.test = 'test'"})
    expect(spec).to map_reduce({}).to({"key" => nil, "value" => "test"})
  end

  it "should handle sum function" do
    spec = double(
      :map_function => "function(doc) { emit(null, doc.age); }",
      :reduce_function => "function(keys, values) { return sum(values); }")
    expect(spec).to map_reduce(@docs).to({"key" => nil, "value" => 103})
  end

  context "without grouping" do
    it "should not group by key by default" do
      expect(@view_spec).to map_reduce(@docs).to({"key" => nil, "value" => 8})
    end

    it "should group by key with :group => false" do
      expect(@view_spec).to map_reduce(@docs).with_options(:group => false).to({"key" => nil, "value" => 8})
    end
  end

  context "with grouping" do
    [true, "exact"].each do |group_value|
      it "should group by the full key with option :group => #{group_value}" do
        expect(@view_spec).to map_reduce(@docs).with_options(:group => group_value).to(
          {"key" => [25, "a"], "value" => 2},
          {"key" => [25, "b"], "value" => 4},
          {"key" => [26, "c"], "value" => 6},
          {"key" => [27, "d"], "value" => 8})
      end
    end

    it "should group by parts of the keys based on the :group_level option" do
      expect(@view_spec).to map_reduce(@docs).with_options(:group_level => 1).to(
        {"key" => [25], "value" => 4},
        {"key" => [26], "value" => 6},
        {"key" => [27], "value" => 8})
    end

    it "should leave non-array keys intact when the :group_level option is specified" do
      @view_spec = double(
        :map_function => "function(doc) {
          for (var i in doc.numbers)
            emit(doc.age, doc.numbers[i]);
          }",
        :reduce_function => "function (keys, values, rereduce) {
            return Math.max.apply(this, values);
          }")
      expect(@view_spec).to map_reduce(@docs).with_options(:group_level => 1).to(
        {"key" => 25, "value" => 4},
        {"key" => 26, "value" => 6},
        {"key" => 27, "value" => 8})
    end
  end

  describe "rereducing" do
    before :each do
      @view_spec = double(:map_function => "function(doc) {
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
      expect(@view_spec).to map_reduce({:name => "a", :number => 1}).to({"key" => nil, "value" => {"rereduce_values" => [[1]]}})
    end

    it "should split and reduce each half of emitted values separately and rereduce the results" do
      docs = [
        {:name => "a", :number => 1},
        {:name => "a", :number => 2},
        {:name => "a", :number => 3},
        {:name => "a", :number => 4}]
      expect(@view_spec).to map_reduce(docs).to({"key" => nil, "value" => {"rereduce_values" => [[1, 2], [3, 4]]}})
    end

    it "should correctly split and rereduce with an odd number of emits" do
      docs = [
        {:name => "a", :number => 1},
        {:name => "a", :number => 2},
        {:name => "a", :number => 3}]
      expect(@view_spec).to map_reduce(docs).to({"key" => nil, "value" => {"rereduce_values" => [[1], [2, 3]]}})
    end
  end

  describe "with key option" do
    it "should return only results for the given key" do
      options = {:key => [25, "a"]}
      results = {"key" => nil, "value" => 2}
      @view_spec.should map_reduce(@docs).with_options(options).to(results)
    end
  end

  describe "with keys option" do
    it "should return only results for the given keys" do
      options = {:group => true, :keys => [[25, "b"], [26, "c"]]}
      results = [{"key" => [25, "b"], "value" => 4}, {"key" => [26, "c"], "value" => 6}]
      @view_spec.should map_reduce(@docs).with_options(options).to(*results)
    end
  end

  describe "with startkey (but no endkey) option" do
    it "should return results with keys from the startkey on" do
      options = {:group_level => 1, :startkey => [26]}
      results = [{"key" => [26], "value" => 6}, {"key" => [27], "value" => 8}]
      @view_spec.should map_reduce(@docs).with_options(options).to(*results)
    end
  end

  describe "with endkey (but no startkey) option" do
    it "should return results with keys up to the endkey" do
      options = {:endkey => [26, "c"]}
      results = {"key" => nil, "value" => 6}
      @view_spec.should map_reduce(@docs).with_options(options).to(results)
    end
  end

  describe "with startkey and endkey options" do
    it "should return only results in the given key range" do
      options = {:group => true, :startkey => [25, "b"], :endkey => [26, "c"]}
      results = [{"key" => [25, "b"], "value" => 4}, {"key" => [26, "c"], "value" => 6}]
      @view_spec.should map_reduce(@docs).with_options(options).to(*results)
    end
  end

  describe "failing specs" do
    it "should have a nice error message for failing should" do
      expect {
        expect(@view_spec).to map_reduce(@docs).with_options(:group => false).to({"key" => nil, "value" => 9})
      }.to raise_error('Expected to map/reduce to [{"key"=>nil, "value"=>9}] but got [{"key"=>nil, "value"=>8}].')
    end

    it "should have a nice error message for failing should not" do
      expect {
        expect(@view_spec).not_to map_reduce(@docs).with_options(:group => false).to({"key" => nil, "value" => 8})
      }.to raise_error('Expected not to map/reduce to [{"key"=>nil, "value"=>8}] but did.')
    end
  end

  describe "couchdb built-in reduce functions" do
    describe "_sum" do
      it "should return the sum of emitted values" do
        spec = double(:map_function => @view_spec.map_function, :reduce_function => "_sum")
        expect(spec).to map_reduce(@docs).to({"key" => nil, "value" => 36})
      end
    end

    describe "_count" do
      it "should return the count of emitted values" do
        spec = double(:map_function => @view_spec.map_function, :reduce_function => "_count")
        expect(spec).to map_reduce(@docs).to({"key" => nil, "value" => 8})
      end
    end

    describe "_stats" do
      it "should return the numerical statistics of emitted values" do
        spec = double(:map_function => @view_spec.map_function, :reduce_function => "_stats")
        expect(spec).to map_reduce(@docs).to({
            "key" => nil,
            "value" => {
              "sum" => 36,
              "count" => 8,
              "min" => 1,
              "max" => 8,
              "sumsqr" => 204
            }
          })
      end
    end
  end
end

describe CouchPotato::RSpec::ListAsMatcher do
  before(:each) do
    @view_spec = double(:list_function => "function() {var row = getRow(); send(JSON.stringify([{text: row.text + ' world'}]));}")
  end

  it "should pass if the function return the expected json" do
    expect(@view_spec).to list({'rows' => [{:text => 'hello'}]}).as([{'text' => 'hello world'}])
  end

  it "should not pass if the function does not return the expected json" do
    expect(@view_spec).not_to list({'rows' => [{:text => 'hello'}]}).as([{'text' => 'hello there'}])
  end

  it "should work with date values" do
    spec = double(:list_function => "function() { send(JSON.stringify([{date: new Date(1368802800000)}])); }")
    expect(spec).to list({"rows" => [{}]}).as([{"date" => "2013-05-17T15:00:00.000Z"}])
  end

  describe "failing specs" do
    it "should have a nice error message for failing should" do
      expect {
        expect(@view_spec).to list({'rows' => [{:text => 'hello'}]}).as([{'text' => 'hello there'}])
      }.to raise_error('Expected to list as [{"text"=>"hello there"}] but got [{"text"=>"hello world"}].')
    end

    it "should have a nice error message for failing should not" do
      expect {
        expect(@view_spec).not_to list({'rows' => [{:text => 'hello'}]}).as([{'text' => 'hello world'}])
      }.to raise_error('Expected to not list as [{"text"=>"hello world"}] but did.')
    end
  end
end
