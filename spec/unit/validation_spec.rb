require 'spec_helper'

describe 'CouchPotato Validation' do
  class Monkey
    include CouchPotato::Persistence
    property :create_property
    property :update_property

    validates :create_property, presence: true, on: :create
    validates :update_property, presence: true, on: :update
  end

  context 'create' do
    let(:monkey) { Monkey.new }

    before do
      monkey.valid?
    end

    it 'has an error on the create property' do
      expect(monkey.errors[:create_property]).to be_present
    end

    it 'has no error on the update property' do
      expect(monkey.errors[:update_property]).not_to be_present
    end
  end

  context 'update' do
    let(:monkey) { Monkey.new _rev: '1' }

    before do
      monkey.valid?
    end

    it 'has no error on the create property' do
      expect(monkey.errors[:create_property]).to_not be_present
    end

    it 'has an error on the update property' do
      expect(monkey.errors[:update_property]).to be_present
    end
  end
end
