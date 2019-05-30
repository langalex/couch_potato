require 'spec_helper'

describe 'CouchPotato Validation' do

  describe "access to errors object" do
    it "adds an errors method the the errors object to be compatible with Validatable" do
      model_class = Class.new
      model_class.send(:include, CouchPotato::Persistence)
      expect(model_class.new.errors).to respond_to(:errors)
    end
  end

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
