require File.dirname(__FILE__) + '/../spec_helper'

describe CouchPotato::Persistence::Finder, 'find' do
  it "should pass the count parameter to the database" do
    database = stub 'database'
    ::CouchPotato::Persistence.stub!(:Db).and_return(database)
    database.should_receive(:view).with(anything, hash_including(:count => 1)).and_return({'rows' => []})
    CouchPotato::Persistence::Finder.new.find Comment, {}, :count => 1
  end
end