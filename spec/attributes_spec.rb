require File.dirname(__FILE__) + '/spec_helper'

describe 'attributes=' do
  
  class Plant
    include CouchPotato::Persistence
    property :leaf_count
  end
  
  it "should assign the attributes" do
    plant = Plant.new 
    plant.attributes = {:leaf_count => 1}
    plant.leaf_count.should == 1
  end
end

describe "attributes" do
  it "should return the attributes" do
    plant = Plant.new :leaf_count => 1
    plant.attributes .should == {:leaf_count => 1}
  end
end