require File.dirname(__FILE__) + '/spec_helper'

class Plate
  include CouchPotato::Persistence
  
  property :food
end

describe 'dirty attribute tracking' do
  describe "save" do
    it "should not save when nothing dirty" do
      plate = Plate.create! :food => 'sushi'
      old_rev = plate._rev
      plate.save
      plate._rev.should == old_rev
    end
    
    it "should save when there are dirty attributes" do
      plate = Plate.create! :food => 'sushi'
      old_rev = plate._rev
      plate.food = 'burger'
      plate.save
      plate._rev.should_not == old_rev
    end
  end
  
  describe "access old values" do
    it "should return the old value" do
      plate = Plate.create! :food => 'sushi'
      plate.food = 'burger'
      plate.food_was.should == 'sushi'
    end
  end
  
  describe "check for dirty" do
    it "should return try if attribute changed" do
      plate = Plate.create! :food => 'sushi'
      plate.food = 'burger'
      plate.should be_food_changed
    end
    
    it "should return false if attribute not changed" do
      plate = Plate.create! :food => 'sushi'
      plate.should_not be_food_changed
    end
  end
end