# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'database caching' do
  let(:couchrest_db) do
    double(:couchrest_db, info: double(:info),
    root: '', get: double.as_null_object)
  end

  let(:db) do
    CouchPotato::Database.new(couchrest_db).tap do |db|
      db.cache = cache
    end
  end

  let(:cache) do
    {}
  end

  it 'gets an object from the cache the 2nd time via #load_documemt' do
    expect(couchrest_db).to receive(:get).with('1').exactly(1).times

    db.load_document '1'
    db.load_document '1'
  end

  it 'gets an object from the cache the 2nd time via #load' do
    expect(couchrest_db).to receive(:get).with('1').exactly(1).times

    db.load '1'
    db.load '1'
  end

  it 'gets an object from the cache the 2nd time via #load!' do
    expect(couchrest_db).to receive(:get).with('1').exactly(1).times

    db.load! '1'
    db.load! '1'
  end

  it 'returns the correct object' do
    doc = double(:doc, 'database=': nil)
    allow(couchrest_db).to receive_messages(get: doc)

    db.load_document '1'
    expect(db.load_document('1')).to eql(doc)
  end

  it 'does not cache bulk loads' do
    allow(couchrest_db).to receive_messages(bulk_load: {'rows' => []})
    expect(couchrest_db).to receive(:bulk_load).with(['1']).exactly(2).times

    db.load_document ['1']
    db.load_document ['1']
  end

  it 'clears the cache when destroying a document via #destroy_document' do
    expect(couchrest_db).to receive(:get).with('1').exactly(2).times

    db.load_document '1'
    db.destroy_document double.as_null_object
    db.load_document '1'
  end

  it 'clears the cache when destroying a document via #destroy' do
    expect(couchrest_db).to receive(:get).with('1').exactly(2).times

    db.load_document '1'
    db.destroy double.as_null_object
    db.load_document '1'
  end

  it 'clears the cache when updating a document via #save_document' do
    expect(couchrest_db).to receive(:get).with('1').exactly(2).times

    db.load_document '1'
    db.save_document double.as_null_object
    db.load_document '1'
  end

  it 'clears the cache when updating a document via #save_document!' do
    expect(couchrest_db).to receive(:get).with('1').exactly(2).times

    db.load_document '1'
    db.save_document! double.as_null_object
    db.load_document '1'
  end

  it 'clears the cache when updating a document via #save' do
    expect(couchrest_db).to receive(:get).with('1').exactly(2).times

    db.load_document '1'
    db.save double.as_null_object
    db.load_document '1'
  end

  it 'clears the cache when updating a document via #save!' do
    expect(couchrest_db).to receive(:get).with('1').exactly(2).times

    db.load_document '1'
    db.save! double.as_null_object
    db.load_document '1'
  end
end
