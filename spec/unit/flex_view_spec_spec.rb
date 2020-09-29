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
