require 'spec_helper'

describe CouchPotato::View::ViewQuery, 'query_view!' do
  let(:db) { double 'db', :get => nil, view: nil, :save_doc => nil,
    connection: double.as_null_object, name: nil }

  before(:each) do
    CouchPotato::View::ViewQuery.clear_cache
  end

  it 'does not pass a key if conditions are empty' do
    expect(db).to receive(:view).with(anything, {})
    CouchPotato::View::ViewQuery.new(db, '', {:view0 => {}}).query_view!
  end

  it 'updates a view if it does not exist' do
    expect(db).to receive(:save_doc).with(
      'views' => {'view' => {'map' => '<map_code>', 'reduce' => '<reduce_code>'}, 'lib' => {'test' => '<lib_code>'}},
      'lists' => {},
      "_id" => "_design/design",
      "language" => "javascript"
    )

    CouchPotato::View::ViewQuery.new(db, 'design', {:view => {:map => '<map_code>', :reduce => '<reduce_code>'}}, nil, {'test' => "<lib_code>"}).query_view!
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
      'views' => {'view' => {'map' => '<map_code>', 'reduce' => '<reduce_code>'}},
      'lists' => {}, "_id" => "_design/design", "language" => "erlang")

    CouchPotato::View::ViewQuery.new(db, 'design',
      {:view => {:map => '<map_code>', :reduce => '<reduce_code>'}},
      nil, nil, :erlang).query_view!
  end

  it "does not update a view when the views object haven't changed" do
    allow(db).to receive(:get).and_return({'views' => {'view' => {'map' => '<map_code>', 'reduce' => '<reduce_code>'}}})
    expect(db).not_to receive(:save_doc)
    CouchPotato::View::ViewQuery.new(db, 'design', {:view => {:map => '<map_code>', :reduce => '<reduce_code>'}}, nil, nil).query_view!
  end

  it "does not update a view when the list function hasn't changed" do
    allow(db).to receive(:get).and_return({'views' => {'view' => {'map' => '<map_code>', 'reduce' => '<reduce_code>'}}, 'lists' => {'list0' => '<list_code>'}})
    expect(db).not_to receive(:save_doc)
    CouchPotato::View::ViewQuery.new(db, 'design', {:view => {:map => '<map_code>', :reduce => '<reduce_code>'}}, :list0 => '<list_code>').query_view!
  end

  it "does not update a view when the lib function hasn't changed" do
    allow(db).to receive(:get).and_return({'views' => {'view' => {'map' => '<map_code>', 'reduce' => '<reduce_code>'}, 'lib' => {'test' => '<lib_code>'}}})

    expect(db).not_to receive(:save_doc)

    CouchPotato::View::ViewQuery.new(db, 'design', {:view => {:map => '<map_code>', :reduce => '<reduce_code>'}}, nil, {'test' => "<lib_code>"}).query_view!
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

  it 'updates a view when the lib hash has changed' do
    allow(db).to receive(:get).and_return({'views' => {'view4' => {'map' => '<map_code>'}}}, 'lib' => {'test' => "<test_lib>"})

    expect(db).to receive(:save_doc)

    CouchPotato::View::ViewQuery.new(db, 'design', {:view4 => {:map => '<map_code>'}}, nil, {:test => "<test_lib>"}).query_view!
  end

  it "doesn't override libs with different names" do
    allow(db).to receive(:get).and_return({'views' => {'view5' => {'map' => '<map_code>'}, 'lib' => {'test' => "<test_lib>"}}})
    expect(db).to receive(:save_doc).with({
      'views' => {
        'view5' => {'map' => '<map_code>'},
        'lib' => {'test' => '<test_lib>', 'test1' => '<test1_lib>'}
      }
    })
    CouchPotato::View::ViewQuery.new(db, 'design', {:view5 => {:map => '<map_code>'}}, nil, {'test1' => '<test1_lib>'}).query_view!
  end

  it 'overrides libs with the same name' do
    allow(db).to receive(:get).and_return({'views' => {'view6' => {'map' => '<map_code>'}, 'lib' => {'test' => "<test_lib>"}}})

    expect(db).to receive(:save_doc).with({
      'views' => {
        'view6' => {'map' => '<map_code>'},
        'lib' => {'test' => '<test1_lib>'}
      },
    })

    CouchPotato::View::ViewQuery.new(db, 'design', {:view6 => {:map => '<map_code>'}}, nil, {'test' => '<test1_lib>'}).query_view!
  end

  it 'does not pass in reduce or lib keys if there is no lib or reduce object' do
    allow(db).to receive(:get).and_return({'views' => {}})
    expect(db).to receive(:save_doc).with('views' => {'view7' => {'map' => '<map code>'}})
    CouchPotato::View::ViewQuery.new(db, 'design', :view7 => {:map => '<map code>', :reduce => nil}).query_view!
  end

  it 'updates a view when the reduce function has changed' do
    allow(db).to receive(:get).and_return({'views' => {'view8' => {'map' => '<map_code>', 'reduce' => '<reduce_code>'}}})
    expect(db).to receive(:save_doc)
    CouchPotato::View::ViewQuery.new(db, 'design', :view8 => {:map => '<map_code>', :reduce => '<new reduce_code>'}).query_view!
  end

  it 'updates a view when the list function has changed' do
    allow(db).to receive(:get).and_return({
      'views' => {'view9' => {'map' => '<map_code>', 'reduce' => '<reduce_code>'}},
      'lists' => {'list1' => '<list_code>'}
      })
    expect(db).to receive(:save_doc)
    CouchPotato::View::ViewQuery.new(db, 'design', {:view9 => {:map => '<map_code>', :reduce => '<reduce_code>'}}, :list1 => '<new_list_code>').query_view!
  end

  it "updates a view when there wasn't a list function but now there is one" do
    allow(db).to receive(:get).and_return({
      'views' => {'view10' => {'map' => '<map_code>', 'reduce' => '<reduce_code>'}}
      })
    expect(db).to receive(:save_doc)
    CouchPotato::View::ViewQuery.new(db, 'design', {:view10 => {:map => '<map_code>', :reduce => '<reduce_code>'}}, :list1 => '<new_list_code>').query_view!
  end

  it "does not update a view when there is a list function but no list function is passed" do
    allow(db).to receive(:get).and_return({
      'views' => {'view11' => {'map' => '<map_code>', 'reduce' => '<reduce_code>'}},
      'lists' => {'list1' => '<list_code>'}
      })
    expect(db).not_to receive(:save_doc)
    CouchPotato::View::ViewQuery.new(db, 'design', {:view11 => {:map => '<map_code>', :reduce => '<reduce_code>'}}, {}).query_view!
  end

  it "does not update a view when there were no lists before and no list function is passed" do
    allow(db).to receive(:get).and_return({
      'views' => {'view12' => {'map' => '<map_code>', 'reduce' => '<reduce_code>'}}
      })
    expect(db).not_to receive(:save_doc)
    CouchPotato::View::ViewQuery.new(db, 'design', {:view12 => {:map => '<map_code>', :reduce => '<reduce_code>'}}, {}).query_view!
  end

  it "queries the database directly when querying a list" do
    allow(db).to receive(:name){'my_database'}

    expect(db.connection).to receive(:get).with('/my_database/_design/my_design/_list/list1/view13?key=1')
    CouchPotato::View::ViewQuery.new(db, 'my_design', {:view13 => {:map => '<map_code>', :reduce => '<reduce_code>'}}, :list1 => '<new_list_code>').query_view!(:key => 1)
  end
end
