require File.dirname(__FILE__) + '/spec_helper'
require File.join(File.dirname(__FILE__), 'fixtures', 'address')
require File.join(File.dirname(__FILE__), 'fixtures', 'person')

class Watch
  include CouchPotato::Persistence
  
  property :time, :type => Time
  property :overwritten_read
  property :overwritten_write
  
  def overwritten_read
    super.to_s
  end
  
  def overwritten_write=(value)
    super value.to_s
  end
end


describe 'properties' do
  before(:all) do
    recreate_db
  end
  
  it "should allow me to overwrite read accessor and call super" do
    Watch.new(:overwritten_read => 1).overwritten_read.should == '1'
  end
  
  it "should allow me to overwrite write accessor and call super" do
    Watch.new(:overwritten_write => 1).overwritten_write.should == '1'
  end
  
  it "should return the property names" do
    Comment.property_names.should == [:created_at, :updated_at, :title]
  end
  
  it "should persist a string" do
    c = Comment.new :title => 'my title'
    CouchPotato.database.save_document! c
    c = CouchPotato.database.load_document c.id
    c.title.should == 'my title'
  end
  
  it "should persist a number" do
    c = Comment.new :title => 3
    CouchPotato.database.save_document! c
    c = CouchPotato.database.load_document c.id
    c.title.should == 3
  end
  
  it "should persist a hash" do
    c = Comment.new :title => {'key' => 'value'}
    CouchPotato.database.save_document! c
    c = CouchPotato.database.load_document c.id
    c.title.should == {'key' => 'value'}
  end
  
  it "should persist a Time object" do
    w = Watch.new :time => Time.now
    CouchPotato.database.save_document! w
    w = CouchPotato.database.load_document w.id
    w.time.year.should == Time.now.year
  end
  
  it "should persist an object" do
    p = Person.new :name => 'Bob'
    a = Address.new :city => 'Denver'
    p.ship_address = a
    CouchPotato.database.save_document! p
    p = CouchPotato.database.load_document p.id
    p.ship_address.should === a
  end
  
  it "should persist null for a null " do
    p = Person.new :name => 'Bob'
    p.ship_address = nil
    CouchPotato.database.save_document! p
    p = CouchPotato.database.load_document p.id
    p.ship_address.should be_nil
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