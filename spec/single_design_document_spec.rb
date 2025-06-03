require 'spec_helper'

describe 'single design document' do
  let(:db) { CouchPotato.database }
  let(:couchrest_db) { db.couchrest_database }

  class Thing1
    include CouchPotato::Persistence

    property :title

    view :all, key: :title
  end

  class Thing2
    include CouchPotato::Persistence

    property :name

    view :all, key: :name
  end

  class Thing3 < Thing1 # should work with inheritance
    property :tag

    view :by_tag, key: :tag
  end

  before(:each) do
    recreate_db
    CouchPotato::Config.single_design_document = true
    CouchPotato.views.select! { |v| [Thing1, Thing2, Thing3].include?(v) } # clear classes from other specs
  end

  after(:each) do
    CouchPotato::Config.single_design_document = false
  end

  it 'creates a single design document for all views' do
    thing1 = Thing1.new title: 't1'
    db.save! thing1
    thing2 = Thing2.new name: 'n2'
    db.save! thing2

    db.view(Thing1.all) # create all views when querying the first one

    expect(couchrest_db.get('_design/couch_potato')['views'].keys)
      .to(eq(['thing1-all', 'thing2-all', 'thing3-by_tag']))
  end

  it 'returns the correct models' do
    thing1 = Thing1.new title: 't1'
    db.save! thing1
    thing2 = Thing2.new name: 'n2'
    db.save! thing2
    thing3 = Thing3.new tag: 'tag1'
    db.save! thing3

    expect(db.view(Thing1.all('t1'))).to eq([thing1])
    expect(db.view(Thing2.all('n2'))).to eq([thing2])
    expect(db.view(Thing3.by_tag('tag1'))).to eq([thing3])
  end
end
