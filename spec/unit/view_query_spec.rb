require 'spec_helper'

describe CouchPotato::View::ViewQuery, 'query_view!' do
  before(:each) do
    CouchRest.stub(:get => nil)
  end

  it "does not pass a key if conditions are empty" do
    db = mock 'db', :get => nil, :save_doc => nil
    db.should_receive(:view).with(anything, {})
    CouchPotato::View::ViewQuery.new(db, '', {:view0 => {}}).query_view!
  end

  it 'updates a view if it does not exist' do
    db = mock 'db', :get => nil, :view => nil

    db.should_receive(:save_doc).with(
      'views' => {'view' => {'map' => '<map_code>', 'reduce' => '<reduce_code>'}, 'lib' => {'test' => '<lib_code>'}},
      'lists' => {},
      "_id" => "_design/design",
      "language" => "javascript"
    )

    CouchPotato::View::ViewQuery.new(db, 'design', {:view => {:map => '<map_code>', :reduce => '<reduce_code>'}}, nil, {'test' => "<lib_code>"}).query_view!
  end

  it 'updates a view in erlang if it does not exist' do
    db = mock 'db', :get => nil, :view => nil

    db.should_receive(:save_doc).with(
      'views' => {'view' => {'map' => '<map_code>', 'reduce' => '<reduce_code>'}},
      'lists' => {}, "_id" => "_design/design", "language" => "erlang")

    CouchPotato::View::ViewQuery.new(db, 'design',
      {:view => {:map => '<map_code>', :reduce => '<reduce_code>'}},
      nil, nil, :erlang).query_view!
  end

  it "does not update a view when the views object haven't changed" do
    db = mock 'db', :get => {'views' => {'view' => {'map' => '<map_code>', 'reduce' => '<reduce_code>'}}}, :view => nil
    db.should_not_receive(:save_doc)
    CouchPotato::View::ViewQuery.new(db, 'design', {:view => {:map => '<map_code>', :reduce => '<reduce_code>'}}, nil, nil).query_view!
  end

  it "does not update a view when the list function hasn't changed" do
    db = mock 'db', :get => {'views' => {'view' => {'map' => '<map_code>', 'reduce' => '<reduce_code>'}}, 'lists' => {'list0' => '<list_code>'}}, :view => nil
    db.should_not_receive(:save_doc)
    CouchPotato::View::ViewQuery.new(db, 'design', {:view => {:map => '<map_code>', :reduce => '<reduce_code>'}}, :list0 => '<list_code>').query_view!
  end

  it "does not update a view when the lib function hasn't changed" do
    db = mock 'db', :get => {'views' => {'view' => {'map' => '<map_code>', 'reduce' => '<reduce_code>'}}, 'lib' => {'test' => '<lib_code>'}}, :view => nil
    db.should_not_receive(:save_doc)
    CouchPotato::View::ViewQuery.new(db, 'design', {:view => {:map => '<map_code>', :reduce => '<reduce_code>'}}, nil, {'test' => "<lib_code>"}).query_view!
  end

  it "updates a view when the map function has changed" do
    db = mock 'db', :get => {'views' => {'view2' => {'map' => '<map_code>', 'reduce' => '<reduce_code>'}}}, :view => nil
    db.should_receive(:save_doc)
    CouchPotato::View::ViewQuery.new(db, 'design', :view2 => {:map => '<new map_code>', :reduce => '<reduce_code>'}).query_view!
  end

  it "updates a view when the map function has changed" do
    db = mock 'db', :get => {'views' => {'view3' => {'map' => '<map_code>'}}}, :view => nil
    db.should_receive(:save_doc)
    CouchPotato::View::ViewQuery.new(db, 'design', :view3 => {:map => '<new map_code>'}).query_view!
  end

  it "updates a view when the lib hash has changed" do
    db = mock 'db', :get => {'views' => {'view4' => {'map' => '<map_code>'}}, 'lib' => {'test' => "<test_lib>"}}, :view => nil
    db.should_receive(:save_doc)
    CouchPotato::View::ViewQuery.new(db, 'design', {:view4 => {:map => '<map_code>'}}, nil, {:test => "<test_lib>"}).query_view!
  end

  it "doesn't override libs with different names" do
    db = mock 'db', :get => {'views' => {'view5' => {'map' => '<map_code>'}, 'lib' => {'test' => "<test_lib>"}}}, :view => nil
    db.should_receive(:save_doc).with({
      'views' => {
         'view5' => {'map' => '<map_code>'},
         'lib' => {'test' => '<test_lib>', 'test1' => '<test1_lib>'}
      }
    })
    CouchPotato::View::ViewQuery.new(db, 'design', {:view5 => {:map => '<map_code>'}}, nil, {'test1' => '<test1_lib>'}).query_view!
  end

  it "overrides libs with the same name" do
    db = mock 'db', :get => {'views' => {'view6' => {'map' => '<map_code>'}, 'lib' => {'test' => "<test_lib>"}}}, :view => nil
    db.should_receive(:save_doc).with({
      'views' => {
         'view6' => {'map' => '<map_code>'},
         'lib' => {'test' => '<test1_lib>'}
      }
    })
    CouchPotato::View::ViewQuery.new(db, 'design', {:view6 => {:map => '<map_code>'}}, nil, {'test' => '<test1_lib>'}).query_view!
  end

  it "does not pass in reduce or lib keys if there is no lib or reduce object" do
    db = mock 'db', :get => {'views' => {}}, :view => nil
    db.should_receive(:save_doc).with('views' => {'view7' => {'map' => '<map code>'}})
    CouchPotato::View::ViewQuery.new(db, 'design', :view7 => {:map => '<map code>', :reduce => nil}).query_view!
  end

  it "updates a view when the reduce function has changed" do
    db = mock 'db', :get => {'views' => {'view8' => {'map' => '<map_code>', 'reduce' => '<reduce_code>'}}}, :view => nil
    db.should_receive(:save_doc)
    CouchPotato::View::ViewQuery.new(db, 'design', :view8 => {:map => '<map_code>', :reduce => '<new reduce_code>'}).query_view!
  end

  it "updates a view when the list function has changed" do
    db = mock 'db', :get => {
      'views' => {'view9' => {'map' => '<map_code>', 'reduce' => '<reduce_code>'}},
      'lists' => {'list1' => '<list_code>'}
      }, :view => nil
    db.should_receive(:save_doc)
    CouchPotato::View::ViewQuery.new(db, 'design', {:view9 => {:map => '<map_code>', :reduce => '<reduce_code>'}}, :list1 => '<new_list_code>').query_view!
  end

  it "updates a view when there wasn't a list function but now there is one" do
    db = mock 'db', :get => {
      'views' => {'view10' => {'map' => '<map_code>', 'reduce' => '<reduce_code>'}}
      }, :view => nil
    db.should_receive(:save_doc)
    CouchPotato::View::ViewQuery.new(db, 'design', {:view10 => {:map => '<map_code>', :reduce => '<reduce_code>'}}, :list1 => '<new_list_code>').query_view!
  end

  it "does not update a view when there is a list function but no list function is passed" do
    db = mock 'db', :get => {
      'views' => {'view11' => {'map' => '<map_code>', 'reduce' => '<reduce_code>'}},
      'lists' => {'list1' => '<list_code>'}
      }, :view => nil
    db.should_not_receive(:save_doc)
    CouchPotato::View::ViewQuery.new(db, 'design', {:view11 => {:map => '<map_code>', :reduce => '<reduce_code>'}}, {}).query_view!
  end

  it "does not update a view when there were no lists before and no list function is passed" do
    db = mock 'db', :get => {
      'views' => {'view12' => {'map' => '<map_code>', 'reduce' => '<reduce_code>'}}
      }, :view => nil
    db.should_not_receive(:save_doc)
    CouchPotato::View::ViewQuery.new(db, 'design', {:view12 => {:map => '<map_code>', :reduce => '<reduce_code>'}}, {}).query_view!
  end

  it "queries CouchRest directly when querying a list" do
    db = stub('db').as_null_object
    CouchRest.should_receive(:get).with('http://127.0.0.1:5984/couch_potato_test/_design/my_design/_list/list1/view13?key=1')
    CouchPotato::View::ViewQuery.new(db, 'my_design', {:view13 => {:map => '<map_code>', :reduce => '<reduce_code>'}}, :list1 => '<new_list_code>').query_view!(:key => 1)
  end

end
