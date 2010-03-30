require 'spec_helper'

class Drink
  include CouchPotato::Persistence
  
  property :alcohol
end

describe "json module" do
  it "should inject JSON.create_id into hash representation of a persistence object" do
    sake = Drink.new(:alcohol => "18%")
    sake.to_hash[JSON.create_id].should eql("Drink")
  end
end