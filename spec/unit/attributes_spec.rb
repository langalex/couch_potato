require File.dirname(__FILE__) + '/../spec_helper'

class Plant
  include CouchPotato::Persistence
  property :leaf_count
  property :typed_leaf_count, :type => Fixnum
end

describe "attributes" do
  
  describe 'attributes=' do
    it "should assign the attributes" do
      plant = Plant.new 
      plant.attributes = {:leaf_count => 1}
      plant.leaf_count.should == 1
    end
  end

  describe "attributes" do
    it "should return the attributes" do
      plant = Plant.new(:leaf_count => 1)
      plant.attributes.should == {:leaf_count => 1, :created_at => nil, :updated_at => nil, :typed_leaf_count => nil}
    end
  end
  
  # useful when loading models from custom views
  describe "accessing ghost attributes" do
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

  describe 'typed attributes' do
    describe "fixnum" do
      before(:each) do
        @plant = Plant.new
      end
      
      it "should convert a string into a finum" do
        @plant.typed_leaf_count = '4'
        @plant.typed_leaf_count.should == 4
      end
      
      it "should leave a fixnum as is" do
        @plant.typed_leaf_count = 4
        @plant.typed_leaf_count.should == 4
      end
      
      it "should leave nil as is" do
        @plant.typed_leaf_count = nil
        @plant.typed_leaf_count.should be_nil
      end
      
      it "should set the attributes to zero if a string given" do
        @plant.typed_leaf_count = 'x'
        @plant.typed_leaf_count.should == 0
      end
      
      it "should parse numbers out of a string" do
        @plant.typed_leaf_count = 'x123'
        @plant.typed_leaf_count.should == 123
      end
      
      it "should set the attributes to nil if given a blank string" do
        @plant.typed_leaf_count = ''
        @plant.typed_leaf_count.should be_nil
      end
    end
  end
end

