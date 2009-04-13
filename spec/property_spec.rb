require File.dirname(__FILE__) + '/spec_helper'

class Watch
  include CouchPotato::Persistence
  
  property :time, :type => Time
end


describe 'properties' do
  before(:all) do
    recreate_db
  end
  
  it "should return the property names" do
    Comment.property_names.should == [:created_at, :updated_at, :title, :commenter]
  end
  
  it "should persist a string" do
    c = Comment.new :title => 'my title'
    c.save!
    c = Comment.find c.id
    c.title.should == 'my title'
  end
  
  it "should persist a number" do
    c = Comment.new :title => 3
    c.save!
    c = Comment.find c.id
    c.title.should == 3
  end
  
  it "should persist a hash" do
    c = Comment.new :title => {'key' => 'value'}
    c.save!
    c = Comment.find c.id
    c.title.should == {'key' => 'value'}
  end
  
  it "should persist a Time object" do
    w = Watch.new :time => Time.now
    w.save!
    w = Watch.find w.id
    w.time.year.should == Time.now.year
  end
  
  describe "predicate" do
    it "should return true if property set" do
      Comment.new(:title => 'title').title?.should be_true
    end
    
    it "should return false if property nil" do
      Comment.new.title?.should be_false
    end
    
    it "should return false if property false" do
      Comment.new(:title => false).title?.should be_false
    end
    
    it "should return false if property blank" do
      Comment.new(:title => '').title?.should be_false
    end
  end
end