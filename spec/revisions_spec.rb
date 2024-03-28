require "spec_helper"

describe CouchPotato::Persistence::Revisions, "#_revisions" do
  let(:db) { CouchPotato.database }

  class Thing
    include CouchPotato::Persistence

    property :title
  end

  before(:each) do
    recreate_db
  end

  it "returns all available revisions of a document" do
    thing = Thing.new title: "t1"
    db.save! thing
    thing.title = "t2"
    db.save! thing

    expect(thing._revisions.map(&:title)).to eq(%w[t1 t2])
    expect(thing._revisions.map { |t| t._rev[0, 1].to_i }).to eq([1, 2])
  end
end
