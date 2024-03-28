# frozen_string_literal: true

require "spec_helper"

RSpec.describe "database caching" do
  let(:couchrest_db) do
    double(:couchrest_db, info: double(:info),
      root: "", get: double.as_null_object)
  end

  let(:db) do
    CouchPotato::Database.new(couchrest_db).tap do |db|
      db.cache = cache
    end
  end

  let(:cache) do
    {}
  end

  context "for a single document" do
    it "gets an object from the cache the 2nd time via #load_documemt" do
      expect(couchrest_db).to receive(:get).with("1").exactly(1).times

      db.load_document "1"
      db.load_document "1"
    end

    it "gets an object from the cache the 2nd time via #load" do
      expect(couchrest_db).to receive(:get).with("1").exactly(1).times

      db.load "1"
      db.load "1"
    end

    it "gets an object from the cache the 2nd time via #load!" do
      expect(couchrest_db).to receive(:get).with("1").exactly(1).times

      db.load! "1"
      db.load! "1"
    end

    it "returns the correct object" do
      doc = double(:doc, "database=": nil)
      allow(couchrest_db).to receive_messages(get: doc)

      db.load_document "1"
      expect(db.load_document("1")).to eql(doc)
    end
  end

  context "for multiple documents" do
    let(:doc1) { double(:doc1, "database=": nil, id: "1") }
    let(:doc2) { double(:doc12, "database=": nil, id: "2") }

    it "only loads uncached documents" do
      allow(couchrest_db).to receive(:bulk_load).with(["1"]).and_return("rows" => [{"doc" => doc1}])
      allow(couchrest_db).to receive(:bulk_load).with(["2"]).and_return("rows" => [{"doc" => doc2}])

      db.load_document(["1"])
      db.load_document(["1", "2"])

      expect(couchrest_db).to have_received(:bulk_load).with(["1"]).exactly(1).times
      expect(couchrest_db).to have_received(:bulk_load).with(["2"]).exactly(1).times
    end

    it "loads nothing if all documents are cached" do
      allow(couchrest_db).to receive(:bulk_load).with(["1", "2"])
        .and_return("rows" => [{"doc" => doc1}, {"doc" => doc2}])

      db.load_document(["1", "2"])
      db.load_document(["1", "2"])

      expect(couchrest_db).to have_received(:bulk_load).with(["1", "2"]).exactly(1).times
    end

    it "returns all requested documents" do
      allow(couchrest_db).to receive(:bulk_load).with(["1"]).and_return("rows" => [{"doc" => doc1}])
      allow(couchrest_db).to receive(:bulk_load).with(["2"]).and_return("rows" => [{"doc" => doc2}])

      db.load_document(["1"])
      result = db.load_document(["1", "2"])

      expect(result).to eql([doc1, doc2])
    end

    it "does not cache documents that do not respond to id" do
      doc1 = {
        "id" => "1"
      }
      allow(couchrest_db).to receive(:bulk_load).with(["1"])
        .and_return("rows" => [{"doc" => doc1}])

      db.load_document(["1"])
      db.load_document(["1"])

      expect(couchrest_db).to have_received(:bulk_load).with(["1"]).exactly(2).times
    end
  end

  context "when switching the database" do
  end

  it "clears the cache when destroying a document via #destroy_document" do
    expect(couchrest_db).to receive(:get).with("1").exactly(2).times

    db.load_document "1"
    db.destroy_document double.as_null_object
    db.load_document "1"
  end

  it "clears the cache when destroying a document via #destroy" do
    expect(couchrest_db).to receive(:get).with("1").exactly(2).times

    db.load_document "1"
    db.destroy double.as_null_object
    db.load_document "1"
  end

  it "clears the cache when updating a document via #save_document" do
    expect(couchrest_db).to receive(:get).with("1").exactly(2).times

    db.load_document "1"
    db.save_document double.as_null_object
    db.load_document "1"
  end

  it "clears the cache when updating a document via #save_document!" do
    expect(couchrest_db).to receive(:get).with("1").exactly(2).times

    db.load_document "1"
    db.save_document! double.as_null_object
    db.load_document "1"
  end

  it "clears the cache when updating a document via #save" do
    expect(couchrest_db).to receive(:get).with("1").exactly(2).times

    db.load_document "1"
    db.save double.as_null_object
    db.load_document "1"
  end

  it "clears the cache when updating a document via #save!" do
    expect(couchrest_db).to receive(:get).with("1").exactly(2).times

    db.load_document "1"
    db.save! double.as_null_object
    db.load_document "1"
  end
end
