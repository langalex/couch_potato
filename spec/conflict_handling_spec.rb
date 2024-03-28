require "spec_helper"

describe "conflict handling" do
  let(:db) { CouchPotato::Database.new(CouchPotato.couchrest_database) }
  class Measurement
    include CouchPotato::Persistence

    property :value
  end

  it "re-runs the block with a reloaded instance and saves again when there is a conflict" do
    measurement = Measurement.new value: 1
    db.save! measurement

    db.couchrest_database.save_doc measurement.reload._document.merge("value" => 2)

    db.save measurement do |m|
      m.value += 1
    end

    expect(measurement.value).to eql(3)
  end

  it "raises an error after 5 tries" do
    couchrest_database = double(:couchrest_database, info: double.as_null_object)
    allow(couchrest_database).to receive(:save_doc).and_raise(CouchRest::Conflict)
    db = CouchPotato::Database.new(couchrest_database)
    measurement = double(:measurement).as_null_object
    allow(measurement).to receive(:run_callbacks).and_yield

    expect {
      db.save(measurement, false) { |m| }
    }.to raise_error(CouchPotato::Conflict)
  end

  it "runs the block before saving" do
    measurement = Measurement.new value: 1
    db.save! measurement

    db.save measurement do |m|
      m.value += 1
    end

    expect(measurement.reload.value).to eql(2)
  end

  it "retries destroying a document" do
    measurement = Measurement.new value: 1
    db.save! measurement

    db.couchrest_database.save_doc measurement.reload._document.merge("value" => 2)
    db.destroy measurement

    expect(measurement.reload).to be_nil
  end
end
