require 'spec_helper'

class Plate
  include CouchPotato::Persistence

  property :food
end

describe 'dirty attribute tracking' do
  before(:each) do
    @couchrest_db = double('database', :save_doc => {'id' => '1', 'rev' => '2'}, :info => nil)
    @db = CouchPotato::Database.new(@couchrest_db)
  end

  describe "save" do
    it "should not save when nothing dirty" do
      plate = Plate.new :food => 'sushi'
      @db.save_document!(plate)
      expect(@couchrest_db).not_to receive(:save_doc)
      @db.save_document(plate)
    end

    it "should return true when not dirty" do
      plate = Plate.new :food => 'sushi'
      @db.save_document!(plate)
      expect(@db.save_document(plate)).to be_truthy
    end

    it "should save when there are dirty attributes" do
      plate = Plate.new :food => 'sushi'
      @db.save_document!(plate)
      plate.food = 'burger'
      expect(@couchrest_db).to receive(:save_doc)
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
        expect(@plate.food_was).to eq('sushi')
      end

      describe "with type BigDecimal" do
        before(:each) do
          class Bowl
            include CouchPotato::Persistence
            property :price
          end
        end
        it "should not dup BigDecimal" do

          expect {
            Bowl.new :price => BigDecimal("5.23")
          }.not_to raise_error
        end

        it "should return the old value" do
          bowl = Bowl.new :price => BigDecimal("5.23")
          bowl.price = BigDecimal("2.23")
          expect(bowl.price_was).to eq(5.23)
        end

      end
    end

    describe "check for dirty" do
      it "should return true if attribute changed" do
        @plate.food = 'burger'
        expect(@plate).to be_food_changed
      end

      it "should return false if attribute not changed" do
        expect(Plate.new).not_to be_food_changed
      end

      it "should return true if forced dirty" do
        @plate.is_dirty
        expect(@plate).to be_dirty
      end
    end
  end

  describe "object loaded from database" do
    before(:each) do
      couchrest_db = double('database', :get => Plate.json_create({'_id' => '1', '_rev' => '2', 'food' => 'sushi', JSON.create_id => 'Plate'}), :info => nil)
      @plate = CouchPotato::Database.new(couchrest_db).load_document '1'
    end

    describe "access old values" do
      it "should return the old value" do
        @plate.food = 'burger'
        expect(@plate.food_was).to eq('sushi')
      end
    end

    describe "check for dirty" do
      it "should return true if attribute changed" do
        @plate.food = 'burger'
        expect(@plate).to be_food_changed
      end

      it "should return false if attribute not changed" do
        expect(@plate).not_to be_food_changed
      end
    end
  end


  describe "after save" do
    it "should reset all attributes to not dirty" do
      couchrest_db = double('database', :get => Plate.json_create({'_id' => '1', '_rev' => '2', 'food' => 'sushi', JSON.create_id => 'Plate'}), :info => nil, :save_doc => {})
      db = CouchPotato::Database.new(couchrest_db)
      @plate = db.load_document '1'
      @plate.food = 'burger'
      db.save! @plate
      expect(@plate).not_to be_food_changed
    end

    it "should reset a forced dirty state" do
      couchrest_db = double('database', :get => Plate.json_create({'_id' => '1', '_rev' => '2', 'food' => 'sushi', JSON.create_id => 'Plate'}), :info => nil, :save_doc => {'rev' =>  '3'})
      db = CouchPotato::Database.new(couchrest_db)
      @plate = db.load_document '1'
      @plate.is_dirty
      db.save! @plate
      expect(@plate).not_to be_dirty
    end
  end

end
