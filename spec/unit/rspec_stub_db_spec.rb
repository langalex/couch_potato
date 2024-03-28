# frozen_string_literal: true

require "spec_helper"
require "couch_potato-rspec"

class WithStubbedView
  include CouchPotato::Persistence

  view :stubbed_view, key: :x
end

describe "stubbing the db" do
  it "replaces CouchPotato.database with a double" do
    CouchPotato.stub_db

    expect(CouchPotato.database).to be_a(RSpec::Mocks::Double)
  end

  it "returns the stub" do
    db = CouchPotato.stub_db

    expect(CouchPotato.database).to eq(db)
  end
end

describe "stubbing a view" do
  before(:each) do
    @db = CouchPotato.stub_db
    @db.stub_view(WithStubbedView, :stubbed_view).with("123").and_return([:result])
  end

  it "stubs the view to return a double" do
    expect(WithStubbedView.stubbed_view("123")).to be_a(RSpec::Mocks::Double)
  end

  it "stubs the database to return fake results when called with the stub" do
    expect(@db.view(WithStubbedView.stubbed_view("123"))).to eq([:result])
  end

  it "stubs the database to return the first fake result" do
    expect(@db.first(WithStubbedView.stubbed_view("123"))).to eq(:result)
    expect(@db.first!(WithStubbedView.stubbed_view("123"))).to eq(:result)
  end

  it "stubs the database to return fake results in batches with no given batch size" do
    @db.stub_view(WithStubbedView, :stubbed_view).with("123").and_return([:result] * 501)

    expect do |b|
      @db.view_in_batches(WithStubbedView.stubbed_view("123"), &b)
    end.to yield_successive_args([:result] * 500, [:result])
  end

  it "stubs the database to return fake results in batches with a given batch size" do
    @db.stub_view(WithStubbedView, :stubbed_view).with("123").and_return([:result] * 3)

    expect do |b|
      @db.view_in_batches(WithStubbedView.stubbed_view("123"), batch_size: 2, &b)
    end.to yield_successive_args([:result] * 2, [:result])
  end

  it "stubs the database to return fake results in batches for multiple view specs" do
    @db.stub_view(WithStubbedView, :stubbed_view).with("123").and_return([:result])
    @db.stub_view(WithStubbedView, :stubbed_view).with("456").and_return([:result2])

    expect do |b|
      @db.view_in_batches(WithStubbedView.stubbed_view("123"), &b)
    end.to yield_successive_args([:result])

    expect do |b|
      @db.view_in_batches(WithStubbedView.stubbed_view("456"), &b)
    end.to yield_successive_args([:result2])
  end

  it "raises an error if there is no first result" do
    @db.stub_view(WithStubbedView, :stubbed_view).and_return([])
    expect do
      @db.first!(WithStubbedView.stubbed_view("123"))
    end.to raise_error(CouchPotato::NotFound)
  end

  it "skips stubbing the first view (i.e. doesn't crash) if the fake result does not respond to first" do
    @db.stub_view(WithStubbedView, :stubbed_view).with("123").and_return(:results)

    expect(@db.view(WithStubbedView.stubbed_view("123"))).to eq(:results)
  end

  it "supports the block style return syntax with `with`" do
    @db.stub_view(WithStubbedView, :stubbed_view).with("123") { :results }

    expect(@db.view(WithStubbedView.stubbed_view("123"))).to eq(:results)
  end

  it "supports the block style return syntax without `with`" do
    @db.stub_view(WithStubbedView, :stubbed_view) { :results }

    expect(@db.view(WithStubbedView.stubbed_view("123"))).to eq(:results)
  end
end
