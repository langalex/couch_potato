require 'spec_helper'

class Branch
  include CouchPotato::Persistence

  property :leafs
end


class Plant
  include CouchPotato::Persistence
  property :leaf_count
  property :typed_leaf_count, :type => Fixnum
  property :typed_leaf_size,  :type => Float
  property :branch, :type => Branch
end


describe "attributes" do
  context 'attributes=' do
    it "should assign the attributes" do
      plant = Plant.new
      plant.attributes = {:leaf_count => 1}
      plant.leaf_count.should == 1
    end

    it "should assign the attributes via []=" do
      plant = Plant.new
      plant[:leaf_count] = 1
      plant.leaf_count.should == 1
    end
  end

  context "attributes" do
    it "should return the attributes" do
      plant = Plant.new(:leaf_count => 1)
      plant.attributes.should == {'leaf_count' => 1, 'created_at' => nil, 'updated_at' => nil,
                                  'typed_leaf_count' => nil, 'typed_leaf_size' => nil, 'branch' => nil}
    end

    it "should return the attributes via [symbol]" do
      plant = Plant.new(:leaf_count => 1)
      plant.attributes[:leaf_count].should eql(plant[:leaf_count])
      plant.attributes[:leaf_count].should eql(1)
    end

    it "should return the attributes via [string]" do
      plant = Plant.new(:leaf_count => 1)
      plant.attributes["leaf_count"].should eql(plant[:leaf_count])
      plant.attributes["leaf_count"].should eql(1)
    end
  end

  context "has_key?" do
    it "should respond to has_key?" do
      plant = Plant.new(:leaf_count => 1)
      plant.has_key?(:leaf_count).should be_true
    end
  end

  # useful when loading models from custom views
  context "accessing ghost attributes" do
    it "should allow me to access attributes that are in the couchdb document but not defined as a property" do
      plant = Plant.json_create({JSON.create_id => "Plant", "color" => "red", "leaf_count" => 1})
      plant.color.should == 'red'
    end

    it "should raise a no method error when trying to read attributes that are not in the document" do
      plant = Plant.json_create({JSON.create_id => "Plant", "leaf_count" => 1})
      lambda do
        plant.length
      end.should raise_error(NoMethodError)
    end

    it "should raise a no method error if the document hasn't been loaded from the database" do
      plant = Plant.new
      lambda do
        plant.length
      end.should raise_error(NoMethodError, /undefined method `length'/)
    end
  end

  context 'typed attributes' do
    before(:each) do
      @plant = Plant.new
    end

    context 'nested objects' do
      it 'assigns the attributes of nested objects' do
        Plant.new(:branch => {:leafs => 3}).branch.leafs.should == 3
      end
    end

    describe "fixnum" do
      it 'rounds a float to a fixnum' do
        @plant.typed_leaf_count = 4.5
        @plant.typed_leaf_count.should == 5
      end

      it "converts a string into a fixnum" do
        @plant.typed_leaf_count = '4'
        @plant.typed_leaf_count.should == 4
      end

      it "converts a string into a negative fixnum" do
        @plant.typed_leaf_count = '-4'
        @plant.typed_leaf_count.should == -4
      end

      it "leaves a fixnum as is" do
        @plant.typed_leaf_count = 4
        @plant.typed_leaf_count.should == 4
      end

      it "leaves nil as is" do
        @plant.typed_leaf_count = nil
        @plant.typed_leaf_count.should be_nil
      end

      it "sets the attributes to zero if a string given" do
        @plant.typed_leaf_count = 'x'
        @plant.typed_leaf_count.should == 0
      end

      it "parses numbers out of a string" do
        @plant.typed_leaf_count = 'x123'
        @plant.typed_leaf_count.should == 123
      end

      it "set the attributes to nil if given a blank string" do
        @plant.typed_leaf_count = ''
        @plant.typed_leaf_count.should be_nil
      end
    end

    context "float" do
      it "should convert a number in a string with a decimal place" do
        @plant.typed_leaf_size = '0.5001'
        @plant.typed_leaf_size.should == 0.5001
      end

      it "should convert a number in a string without a decimal place" do
        @plant.typed_leaf_size = '5'
        @plant.typed_leaf_size.should == 5.0
      end

      it "should convert a negative number in a string" do
        @plant.typed_leaf_size = '-5.0'
        @plant.typed_leaf_size.should == -5.0
      end

      it "should leave a float as it is" do
        @plant.typed_leaf_size = 0.5
        @plant.typed_leaf_size.should == 0.5
      end

      it "should leave nil as is" do
        @plant.typed_leaf_size = nil
        @plant.typed_leaf_size.should be_nil
      end

      it "should set the attributes to zero if a string given" do
        @plant.typed_leaf_size = 'x'
        @plant.typed_leaf_size.should == 0
      end

      it "should parse numbers out of a string" do
        @plant.typed_leaf_size = 'x00.123'
        @plant.typed_leaf_size.should == 0.123
      end

      it "should set the attributes to nil if given a blank string" do
        @plant.typed_leaf_size = ''
        @plant.typed_leaf_size.should be_nil
      end
    end
  end
end
