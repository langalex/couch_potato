require 'spec_helper'

class Drink
  include CouchPotato::Persistence
  
  property :alcohol
end

describe CouchPotato::Persistence::Json do
  context '#to_hash' do
    it "should inject JSON.create_id into the hash representation of a persistent object" do
      sake = Drink.new(:alcohol => "18%")
      sake.to_hash[JSON.create_id].should eql("Drink")
    end
  end
  
  context '.json_create' do
    it 'should assign the _document' do
      sake = Drink.json_create({"alcohol" => "18%"})
      sake._document.should == {"alcohol" => "18%"}
    end
  end
  
end