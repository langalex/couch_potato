require 'spec_helper'

describe CouchPotato::View::ViewQuery, 'query_view!' do
  let(:db) { double 'db', :get => nil, view: nil, :save_doc => nil,
    connection: double.as_null_object, name: nil }

  before(:each) do
    CouchPotato::View::ViewQuery.clear_cache
  end

  after(:each) do
    CouchPotato::Config.single_design_document = false
    CouchPotato::Config.digest_view_names = false
  end

  it 'does not pass a key if conditions are empty' do
    expect(db).to receive(:view).with(anything, {})
    CouchPotato::View::ViewQuery.new(db, '', {:view0 => {}}).query_view!
  end

  it 'updates a view if it does not exist' do
    expect(db).to receive(:save_doc).with(
      {
        'views' => {'view' => {'map' => '<map_code>', 'reduce' => '<reduce_code>'}},
        "_id" => "_design/design",
        "language" => "javascript"
        }
    )

    CouchPotato::View::ViewQuery.new(db, 'design', {:view => {:map => '<map_code>', :reduce => '<reduce_code>'}}).query_view!
  end

  it 'only updates a view once' do
    allow(db).to receive(:get).and_return({'views' => {}}, {'views' => {}, x: 1}) # return something different on the second call otherwise it would never try to update the views twice
    query = CouchPotato::View::ViewQuery.new(db, 'design', {:view => {:map => '<map_code>', :reduce => '<reduce_code>'}})

    expect(db).to receive(:save_doc).once

    2.times { query.query_view! }
  end

  it 'updates a view again after clearing the view cache' do
    allow(db).to receive(:get).and_return({'views' => {}}, {'views' => {}, x: 1}) # return something different on the second call otherwise it would never try to update the views twice
    query = CouchPotato::View::ViewQuery.new(db, 'design', {:view => {:map => '<map_code>', :reduce => '<reduce_code>'}})

    expect(db).to receive(:save_doc).twice

    query.query_view!
    CouchPotato::View::ViewQuery.clear_cache
    query.query_view!
  end

  it 'updates a view in erlang if it does not exist' do
    expect(db).to receive(:save_doc).with(
      {
        'views' => {'view' => {'map' => '<map_code>', 'reduce' => '<reduce_code>'}},
        "_id" => "_design/design", "language" => "erlang"
      }
    )

    CouchPotato::View::ViewQuery.new(db, 'design',
      {:view => {:map => '<map_code>', :reduce => '<reduce_code>'}},
      :erlang).query_view!
  end

  it "does not update a view when the views object haven't changed" do
    allow(db).to receive(:get).and_return({'views' => {'view' => {'map' => '<map_code>', 'reduce' => '<reduce_code>'}}})
    expect(db).not_to receive(:save_doc)
    CouchPotato::View::ViewQuery.new(db, 'design', {:view => {:map => '<map_code>', :reduce => '<reduce_code>'}}).query_view!
  end

  it 'updates a view when the map function has changed' do
    allow(db).to receive(:get).and_return({'views' => {'view2' => {'map' => '<map_code>', 'reduce' => '<reduce_code>'}}})
    expect(db).to receive(:save_doc)
    CouchPotato::View::ViewQuery.new(db, 'design', :view2 => {:map => '<new map_code>', :reduce => '<reduce_code>'}).query_view!
  end

  it 'updates a view when the map function has changed' do
    allow(db).to receive(:get).and_return({'views' => {'view3' => {'map' => '<map_code>'}}})
    expect(db).to receive(:save_doc)
    CouchPotato::View::ViewQuery.new(db, 'design', :view3 => {:map => '<new map_code>'}).query_view!
  end

  it 'updates a view when the reduce function has changed' do
    allow(db).to receive(:get).and_return({'views' => {'view8' => {'map' => '<map_code>', 'reduce' => '<reduce_code>'}}})
    expect(db).to receive(:save_doc)
    CouchPotato::View::ViewQuery.new(db, 'design', :view8 => {:map => '<map_code>', :reduce => '<new reduce_code>'}).query_view!
  end

  it 'adds a digest of all views to the design document if single_design_doc is true' do
    CouchPotato::Config.single_design_document = true
    CouchPotato::Config.digest_view_names = true

    allow(db).to receive(:get).and_return(nil)
    allow(db).to receive(:save_doc).and_return(true)
    view_class = double('view_class',
      views: {view: {map: '<map_code>'}},
      execute_view: double('view_spec', view_name: 'view', map_function: '<map_code>', reduce_function: nil))
    allow(CouchPotato).to receive(:views).and_return([view_class])

    CouchPotato::View::ViewQuery.new(
      db, 
      'couch_potato',
      {:view => {:map => '<map_code>'}}).query_view!

    expect(db).to have_received(:save_doc).with(hash_including({"_id" => "_design/couch_potato-56d286b4f0cd3a50fdd2ad428034d08a6483311539f7e138c45e781611b9dbbc"}))
  end
end