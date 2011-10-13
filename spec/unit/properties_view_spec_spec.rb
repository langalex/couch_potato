require 'spec_helper'
require 'couch_potato/rspec'

class Contract
  include CouchPotato::Persistence

  property :date
  property :terms

  view :by_date, :type => :properties, :key => :_id, :properties => [:date]
end

describe CouchPotato::View::PropertiesViewSpec do
  before(:each) do
    @default_language = CouchPotato::Config.default_language
  end

  after(:each) do
    CouchPotato::Config.default_language = @default_language
  end

  it "should map the given properties" do
    Contract.by_date.should map(
      Contract.new(:date => '2010-01-01', :_id => '1')
    ).to(['1', {"date" => "2010-01-01"}])
  end

  it "should reduce to the number of documents" do
    Contract.by_date.should reduce(
      ['1', {"date" => "2010-01-01"}], ['2', {"date" => "2010-01-02"}]
    ).to(2)
  end

  it "should rereduce the number of documents" do
    Contract.by_date.should rereduce(
      nil, [12, 13]
    ).to(25)
  end

  it 'always uses javascript' do
    CouchPotato::Config.default_language = :erlang
    CouchPotato::View::PropertiesViewSpec.new(Contract, 'all', {}, {}).language.should == :javascript
  end
end
