require File.dirname(__FILE__) + '/../spec_helper'

class Plate
  include CouchPotato::Persistence
  
  property :food
end

describe 'dirty attribute tracking' do
  before(:each) do
    @db = stub('db', :save_doc => {'rev' => '1', 'id' => '2'})
    Plate.db = @db
  end
  
  after(:each) do
    Plate.db = nil
  end
  
  describe "save" do
    it "should not save when nothing dirty" do
      plate = Plate.new :food => 'sushi'
      plate.persister = Persister.new @db
      plate.save!
      plate.persister.should_not_receive(:save_document)
      plate.save
    end
    
    it "should save when there are dirty attributes" do
      plate = Plate.create! :food => 'sushi'
      plate.persister = Persister.new @db
      plate.food = 'burger'
      plate.persister.should_receive(:save_document)
      plate.save
    end
  end
  
  describe "newly created object" do
    
    before(:each) do
      @plate = Plate.new :food => 'sushi'
    end
    
    describe "access old values" do
      it "should return the old value" do
        @plate.food = 'burger'
        @plate.food_was.should == 'sushi'
      end
    end

    describe "check for dirty" do
      it "should return true if attribute changed" do
        @plate.food = 'burger'
        @plate.should be_food_changed
      end

      it "should return false if attribute not changed" do
        @plate.should_not be_food_changed
      end
      
      it "should return false if attribute forced not changed" do
        @plate.food = 'burger'
        @plate.food_not_changed
        @plate.should_not be_food_changed
      end
    end
  end
  
  describe "object loaded from database" do
    before(:each) do
      Plate.db = stub('db', :get => {'_id' => '1', '_rev' => '2', 'food' => 'sushi'})
      @plate = Plate.get '1'
    end
    
    describe "access old values" do
      it "should return the old value" do
        @plate.food = 'burger'
        @plate.food_was.should == 'sushi'
      end
    end

    describe "check for dirty" do
      it "should return true if attribute changed" do
        @plate.food = 'burger'
        @plate.should be_food_changed
      end

      it "should return false if attribute not changed" do
        @plate.should_not be_food_changed
      end
    end
  end
  
  
end