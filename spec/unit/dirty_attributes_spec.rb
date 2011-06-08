require 'spec_helper'

class Plate
  include CouchPotato::Persistence
  
  property :food
  property :comments, :type => Array, :default => []
end

describe 'dirty attribute tracking' do
  before(:each) do
    @couchrest_db = stub('database', :save_doc => {'id' => '1', 'rev' => '2'}, :info => nil)
    @db = CouchPotato::Database.new(@couchrest_db)
  end
  
  describe "save" do
    it "should not save when nothing dirty" do
      plate = Plate.new :food => 'sushi'
      @db.save_document!(plate)
      @couchrest_db.should_not_receive(:save_doc)
      @db.save_document(plate)
    end
    
    it "should return true when not dirty" do
      plate = Plate.new :food => 'sushi'
      @db.save_document!(plate)
      @db.save_document(plate).should be_true
    end
    
    it "should save when there are dirty attributes" do
      plate = Plate.new :food => 'sushi'
      @db.save_document!(plate)
      plate.food = 'burger'
      @couchrest_db.should_receive(:save_doc)
      @db.save_document(plate)
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
      
      describe "with type BigDecimal" do
        before(:each) do
          class Bowl
            include CouchPotato::Persistence
            property :price
          end
        end
        it "should not dup BigDecimal" do

          lambda {
            Bowl.new :price => BigDecimal.new("5.23") 
          }.should_not raise_error(TypeError)
        end
        
        it "should return the old value" do
          bowl = Bowl.new :price => BigDecimal.new("5.23") 
          bowl.price = BigDecimal.new("2.23")
          bowl.price_was.should == 5.23
        end
        
      end
    end

    describe "check for dirty" do
      it "should return true if attribute changed" do
        @plate.food = 'burger'
        @plate.should be_food_changed
      end

      it "should return false if attribute not changed" do
        Plate.new.should_not be_food_changed
      end
      
      it "should return true if forced dirty" do
        @plate.is_dirty
        @plate.should be_dirty
      end
    end
  end
  
  describe "object loaded from database" do
    before(:each) do
      couchrest_db = stub('database', :get => Plate.json_create({'_id' => '1', '_rev' => '2', 'food' => 'sushi', JSON.create_id => 'Plate'}), :info => nil)
      @plate = CouchPotato::Database.new(couchrest_db).load_document '1'
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
  
  
  describe "after save" do
    it "should reset all attributes to not dirty" do
      couchrest_db = stub('database', :get => Plate.json_create({'_id' => '1', '_rev' => '2', 'food' => 'sushi', JSON.create_id => 'Plate'}), :info => nil, :save_doc => {})
      db = CouchPotato::Database.new(couchrest_db)
      @plate = db.load_document '1'
      @plate.food = 'burger'
      db.save! @plate
      @plate.should_not be_food_changed
    end
    
    it "should reset a forced dirty state" do
      couchrest_db = stub('database', :get => Plate.json_create({'_id' => '1', '_rev' => '2', 'food' => 'sushi', JSON.create_id => 'Plate'}), :info => nil, :save_doc => {'rev' =>  '3'})
      db = CouchPotato::Database.new(couchrest_db)
      @plate = db.load_document '1'
      @plate.is_dirty
      db.save! @plate
      @plate.should_not be_dirty
    end
  end

  describe "type array" do
    it "should be dirty when added through << method" do
      plate = Plate.new
      plate.comments << {:body => "hi"}
      plate.should be_dirty
    end

    it "should be dirty when added through += assignment" do
      plate = Plate.new
      plate.comments += [{:body => "hi"}]
      plate.should be_dirty
    end
  end
  
end
