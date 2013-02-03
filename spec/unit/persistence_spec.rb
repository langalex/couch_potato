require 'spec_helper'

class Dude
  include CouchPotato::Persistence
  property :name
end

class NoneDude
  include CouchPotato::Persistence
  property :name
end

describe "persistence" do
  context '#eql?' do
    it "should use the class and id for equality" do
      dude22 = Dude.new(:id => "22", :name => "foo")
      dude11 = Dude.new(:id => "11", :name => "bar")

      none_dude22 = NoneDude.new(:id => "22", :name => "foo")

      dude22.should eql(dude22)
      dude22.should_not eql(none_dude22)
      dude22.should_not eql(dude11)
    end

    it "should handle new objects without id to be never equal" do
      dude = Dude.new(:name => "foo")
      dude22 = Dude.new(:id => "22", :name => "foo")

      dude.should_not eql(Dude.new(:name => "foo"))
      dude22.should_not eql(Dude.new(:name => "foo"))
    end

    it "should handle same object references to be equal" do
      dude = Dude.new(:name => "foo")

      dude.should eql(dude)
    end
  end
end