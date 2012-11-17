require 'spec_helper'

describe CouchPotato::View::CustomViewSpec, '#process_results' do
  it 'returns the documents' do
    spec = CouchPotato::View::CustomViewSpec.new(Child, 'all', {}, {})
    processed_results = spec.process_results('rows' => [{'doc' => {JSON.create_id => 'Child'}}])

    expect(processed_results.map{|row| row.class}).to eql([Child])
  end

  it 'returns values where there are no documents' do
    spec = CouchPotato::View::CustomViewSpec.new(Child, 'all', {}, {:include_docs => false})
    processed_results = spec.process_results('rows' => [{'value' => {JSON.create_id => 'Child'}}])

    expect(processed_results.map{|row| row.class}).to eql([Child])
  end

  it 'filters out rows without documents when include_docs=true (i.e. doc has been deleted)' do
    spec = CouchPotato::View::CustomViewSpec.new(Child, 'all', {}, {:include_docs => true})
    processed_results = spec.process_results('rows' => [{'value' => {JSON.create_id => 'Child'}}])

    expect(processed_results).to be_empty
  end
end
