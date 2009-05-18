require File.dirname(__FILE__) + '/../spec_helper'

describe CouchPotato::Database, 'new' do
  it "should raise an exception if the database doesn't exist" do
    lambda {
      CouchPotato::Database.new CouchRest.database('couch_potato_invalid')
    }.should raise_error('Database \'couch_potato_invalid\' does not exist.')
  end
end

describe CouchPotato::Database, 'load' do
  it "should raise an exception if nil given" do
    db = CouchPotato::Database.new(stub('couchrest db', :info => nil))
    lambda {
      db.load nil
    }.should raise_error("Can't load a document without an id (got nil)")
  end
end