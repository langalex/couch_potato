require 'spec_helper'

describe "automatic view updates" do
  before(:each) do
    recreate_db
    @db = CouchPotato.couchrest_database
  end
  
  it "should update a view that doesn't match the given functions" do
    CouchPotato::View::ViewQuery.new(@db, 'test_design1', {'test_view' => {:map => 'function(doc) {}', :reduce => 'function() {}'}}, nil).query_view! # create view
    CouchPotato::View::ViewQuery.new(@db, 'test_design1', {'test_view' => {:map => 'function(doc) {emit(doc.id, null)}', :reduce => 'function(key, values) {return sum(values)}'}}, nil).query_view!
    expect(CouchPotato.database.load('_design/test_design1')['views']['test_view']).to eq({
      'map' => 'function(doc) {emit(doc.id, null)}',
      'reduce' => 'function(key, values) {return sum(values)}'
    })
  end
  
  it "should only update a view once to avoid writing the view for every request" do
    CouchPotato::View::ViewQuery.new(@db, 'test_design2', {'test_view' => {:map => 'function(doc) {}', :reduce => 'function() {}'}}, nil).query_view! # create view
    CouchPotato::View::ViewQuery.new(@db, 'test_design2', {'test_view' => {:map => 'function(doc) {emit(doc.id, null)}', :reduce => 'function(key, values) {return sum(values)}'}}, nil).query_view!
    CouchPotato::View::ViewQuery.new(@db, 'test_design2', {'test_view' => {:map => 'function(doc) {}', :reduce => 'function() {}'}}, nil).query_view!
    expect(CouchPotato.database.load('_design/test_design2')['views']['test_view']).to eq({
      'map' => 'function(doc) {emit(doc.id, null)}',
      'reduce' => 'function(key, values) {return sum(values)}'
    })
  end
  
end
