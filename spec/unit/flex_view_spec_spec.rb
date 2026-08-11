# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CouchPotato::View::FlexViewSpec::Results, '#reduce_count' do
  it 'returns the value of the first row (which is the result of reduce)' do
    result = CouchPotato::View::FlexViewSpec::Results.new 'rows' => [{ 'value' => 3 }]

    expect(result.reduce_count).to eq(3)
  end

  it 'returns 0 if there is no first row (empty result set)' do
    result = CouchPotato::View::FlexViewSpec::Results.new 'rows' => []

    expect(result.reduce_count).to eq(0)
  end
end

RSpec.describe CouchPotato::View::FlexViewSpec::Results, '#docs' do
  it 'sets the database on each doc' do
    db = double('db')
    doc = double('doc', 'database=': nil)

    result = CouchPotato::View::FlexViewSpec::Results.new 'rows' => [{ 'doc' => doc }]
    result.database = db

    result.docs

    expect(doc).to have_received(:database=).with(db)
  end

  it 'sets all docs as database_collection on each doc' do
    doc = double('doc', 'database_collection=': nil)

    result = CouchPotato::View::FlexViewSpec::Results.new 'rows' => [{ 'doc' => doc }]

    result.docs

    expect(doc).to have_received(:database_collection=).with([doc])
  end

  it 'returns the docs' do
  end
end

RSpec.describe CouchPotato::View::FlexViewSpec, '#view_parameters=' do
  it 'updates view parameters on the delegate' do
    klass = Class.new do
      def self.name
        'FlexViewParamsModel'
      end
    end
    spec = CouchPotato::View::FlexViewSpec.new(klass, 'by_x', { key: :x }, {})

    spec.view_parameters = spec.view_parameters.merge(limit: 1)

    expect(spec.view_parameters[:limit]).to eq(1)
  end
end