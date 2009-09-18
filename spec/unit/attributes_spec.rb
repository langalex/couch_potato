require File.dirname(__FILE__) + '/../spec_helper'

class Plant
  include CouchPotato::Persistence
  property :leaf_count
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
      plant.attributes.should == {:leaf_count => 1, :created_at => nil, :updated_at => nil}
    end
  end
  
  # useful when loading models from custom views
  describe "accessing ghost attributes" do
    it "should allow me to access attributes that are in the couchdb document but not defined as a property" do
      plant = Plant.json_create({"ruby_class" => "Plant", "color" => "red", "leaf_count" => 1})
      plant.color.should == 'red'
    end
    
    it "should raise a no method error when trying to read attributes that are not in the document" do
      plant = Plant.json_create({"ruby_class" => "Plant", "leaf_count" => 1})
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

end

