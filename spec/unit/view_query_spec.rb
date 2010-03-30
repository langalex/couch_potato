require 'spec_helper'

describe CouchPotato::View::ViewQuery, 'query_view' do
  it "should not pass a key if conditions are empty" do
    db = mock 'db', :get => nil, :save_doc => nil
    db.should_receive(:view).with(anything, {})
    CouchPotato::View::ViewQuery.new(db, '', '', '', '').query_view!
  end
  
  it "should not update a view when the functions haven't changed" do
    db = mock 'db', :get => {'views' => {'view' => {'map' => 'map', 'reduce' => 'reduce'}}}, :view => nil
    db.should_not_receive(:save_doc)
    CouchPotato::View::ViewQuery.new(db, 'design', 'view', 'map', 'reduce').query_view!
  end
  
  it "should update a view when the functions have changed" do
    db = mock 'db', :get => {'views' => {'view2' => {'map' => 'map', 'reduce' => 'reduce'}}}, :view => nil
    db.should_receive(:save_doc)
    CouchPotato::View::ViewQuery.new(db, 'design', 'view2', 'mapnew', 'reduce').query_view!
  end
end