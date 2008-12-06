require File.dirname(__FILE__) + '/../spec_helper'

describe CouchPotato::Persistence::ViewQuery, 'query_view' do
  it "should not pass a key if conditions are empty" do
    db = mock 'db'
    db.should_receive(:view).with(anything, {})
    ::CouchPotato::Persistence.stub!(:Db).and_return(db)
    CouchPotato::Persistence::ViewQuery.new('', '', '', '', {}).query_view!
  end
end