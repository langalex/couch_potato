require 'spec_helper'

class Branch
  include CouchPotato::Persistence

  property :leafs
end

class Plant
  include CouchPotato::Persistence
  property :leaf_count
  property :typed_leaf_count, type: Integer
  property :typed_leaf_size,  type: Float
  property :branch, type: Branch
end

class SpecialPlant < Plant
end


describe 'attributes' do
  context 'attributes=' do
    it 'assigns the attributes' do
      plant = Plant.new
      plant.attributes = {leaf_count: 1}

      expect(plant.leaf_count).to eq(1)
    end

    it 'assigns the attributes via []=' do
      plant = Plant.new
      plant[:leaf_count] = 1

      expect(plant.leaf_count).to eq(1)
    end
  end

  context 'attributes' do
    it 'returns the attributes' do
      plant = Plant.new(leaf_count: 1)

      expect(plant.attributes).to eq('leaf_count' => 1, 'created_at' => nil,
        'updated_at' => nil, 'typed_leaf_count' => nil,
        'typed_leaf_size' => nil, 'branch' => nil)
    end

    it 'returns the attributes via [symbol]' do
      plant = Plant.new(leaf_count: 1)

      expect(plant.attributes[:leaf_count]).to eql(plant[:leaf_count])
      expect(plant.attributes[:leaf_count]).to eql(1)
    end

    it 'returns the attributes via [string]' do
      plant = Plant.new(leaf_count: 1)

      expect(plant.attributes['leaf_count']).to eql(plant[:leaf_count])
      expect(plant.attributes['leaf_count']).to eql(1)
    end
  end

  context 'has_key?' do
    it 'responds to has_key?' do
      plant = Plant.new(leaf_count: 1)

      expect(plant.has_key?(:leaf_count)).to be_truthy
    end
  end

  context 'inherited attributes' do
    it 'returns inherited attributes' do
      plant = SpecialPlant.new _document: {leaf_count: 1}

      expect(plant.leaf_count).to eq(1)
    end
  end

  context 'typed attributes' do
    before(:each) do
      @plant = Plant.new
    end

    context 'nested objects' do
      it 'assigns the attributes of nested objects' do
        expect(Plant.new(branch: {leafs: 3}).branch.leafs).to eq(3)
      end
    end

    describe 'fixnum' do
      it 'rounds a float to a fixnum' do
        @plant.typed_leaf_count = 4.5

        expect(@plant.typed_leaf_count).to eq(5)
      end

      it 'converts a string into a fixnum' do
        @plant.typed_leaf_count = '4'

        expect(@plant.typed_leaf_count).to eq(4)
      end

      it 'converts a string into a negative fixnum' do
        @plant.typed_leaf_count = '-4'

        expect(@plant.typed_leaf_count).to eq(-4)
      end

      it 'leaves a fixnum as is' do
        @plant.typed_leaf_count = 4

        expect(@plant.typed_leaf_count).to eq(4)
      end

      it 'leaves nil as is' do
        @plant.typed_leaf_count = nil

        expect(@plant.typed_leaf_count).to be_nil
      end

      it 'sets the attributes to zero if a string given' do
        @plant.typed_leaf_count = 'x'

        expect(@plant.typed_leaf_count).to eq(0)
      end

      it 'parses numbers out of a string' do
        @plant.typed_leaf_count = 'x123'

        expect(@plant.typed_leaf_count).to eq(123)
      end

      it 'sets the attributes to nil if given a blank string' do
        @plant.typed_leaf_count = ''

        expect(@plant.typed_leaf_count).to be_nil
      end
    end

    context 'float' do
      it 'converts a number in a string with a decimal place' do
        @plant.typed_leaf_size = '0.5001'

        expect(@plant.typed_leaf_size).to eq(0.5001)
      end

      it 'converts a number in a string without a decimal place' do
        @plant.typed_leaf_size = '5'

        expect(@plant.typed_leaf_size).to eq(5.0)
      end

      it 'converts a negative number in a string' do
        @plant.typed_leaf_size = '-5.0'

        expect(@plant.typed_leaf_size).to eq(-5.0)
      end

      it 'leaves a float as it is' do
        @plant.typed_leaf_size = 0.5

        expect(@plant.typed_leaf_size).to eq(0.5)
      end

      it 'leaves nil as is' do
        @plant.typed_leaf_size = nil

        expect(@plant.typed_leaf_size).to be_nil
      end

      it 'sets the attributes to zero if a string given' do
        @plant.typed_leaf_size = 'x'

        expect(@plant.typed_leaf_size).to eq(0)
      end

      it 'parses numbers out of a string' do
        @plant.typed_leaf_size = 'x00.123'

        expect(@plant.typed_leaf_size).to eq(0.123)
      end

      it 'sets the attributes to nil if given a blank string' do
        @plant.typed_leaf_size = ''

        expect(@plant.typed_leaf_size).to be_nil
      end
    end
  end
end
