require 'spec_helper'
require 'fixtures/address'
require 'fixtures/person'

class Watch
  include CouchPotato::Persistence
  
  property :time, :type => Time
  property :date, :type => Date
  property :overwritten_read
  property :overwritten_write
  
  def overwritten_read
    super.to_s
  end
  
  def overwritten_write=(value)
    super value.to_s
  end
end

class CuckooClock < Watch
  property :cuckoo
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
  
  def it_should_persist value
    c = Comment.new :title => value
    CouchPotato.database.save_document! c
    c = CouchPotato.database.load_document c.id
    c.title.should == value
  end

  it "should persist a child class" do
    it_should_persist Child.new('text' => 'some text')
  end

  it "should persist a hash with a child class" do
    it_should_persist 'child' => Child.new('text' => 'some text')
  end

  it "should persist an array with a child class" do
    it_should_persist [Child.new('text' => 'some text')]
  end

  it "should persist something very complex" do
    something_very_complex = [
      [
        [
          {
            'what' => [
              {
                'ever' => Child.new('text' => 'some text')
              }
            ],
            'number' => 3
          },
          "string"
        ],
        Child.new('text' => 'nothing')
      ]
    ]
    it_should_persist something_very_complex
  end
  
  it "should persist an object" do
    p = Person.new
    a = Address.new :city => 'Denver'
    p.ship_address = a
    CouchPotato.database.save_document! p
    p = CouchPotato.database.load_document p.id
    p.ship_address.should === a
  end
  
  it "should persist null for a null " do
    p = Person.new
    p.ship_address = nil
    CouchPotato.database.save_document! p
    p = CouchPotato.database.load_document p.id
    p.ship_address.should be_nil
  end
  
  it "should actually pass the null value down in the JSON document " do
    p = Person.new
    p.ship_address = nil
    db = mock(:database)
    db.should_receive(:save_doc).with do |attributes|
      attributes.has_key?(:ship_address).should == true
    end.and_return({})
    CouchPotato.database.stub(:couchrest_database).and_return(db)
    CouchPotato.database.save_document! p
  end

  it "should persist false for a false" do
    p = Person.new
    p.ship_address = false
    CouchPotato.database.save_document! p
    p = CouchPotato.database.load_document p.id
    p.ship_address.should be_false
  end
  
  describe "time properties" do
    it "should persist a Time as utc" do
      time = Time.now
      w = Watch.new :time => time
      CouchPotato.database.save_document! w
      w = CouchPotato.database.load_document w.id
      w.time.to_s.should == time.utc.to_s
    end
    
    it "should parse a string and persist it as utc time" do
      w = Watch.new :time => '2009-01-01 13:25 +0100'
      CouchPotato.database.save_document! w
      w = CouchPotato.database.load_document w.id
      w.time.should be_a(Time)
      w.time.should == Time.parse('2009-01-01 12:25 +0000')
    end
    
    it "should store nil" do
      w = Watch.new :time => nil
      CouchPotato.database.save_document! w
      w = CouchPotato.database.load_document w.id
      w.time.should be_nil
    end
    
    it "should store an empty string as nil" do
      w = Watch.new :time => ''
      CouchPotato.database.save_document! w
      w = CouchPotato.database.load_document w.id
      w.time.should be_nil
    end
  end
  
  describe "date properties" do
    it "should persist a date" do
      date = Date.today
      w = Watch.new :date => date
      CouchPotato.database.save_document! w
      w = CouchPotato.database.load_document w.id
      w.date.should == date
    end
    
    it "should parse a string and persist it as a date" do
      w = Watch.new :date => '2009-01-10'
      CouchPotato.database.save_document! w
      w = CouchPotato.database.load_document w.id
      w.date.should == Date.parse('2009-01-10')
    end
    
    it "should store nil" do
      w = Watch.new :date => nil
      CouchPotato.database.save_document! w
      w = CouchPotato.database.load_document w.id
      w.date.should be_nil
    end
    
    it "should store an empty string as nil" do
      w = Watch.new :date => ''
      CouchPotato.database.save_document! w
      w = CouchPotato.database.load_document w.id
      w.date.should be_nil
    end
  end
  
  describe "boolean properties" do
    it "should persist '0' for false" do
      a = Address.new
      a.verified = '0'
      CouchPotato.database.save_document! a
      a = CouchPotato.database.load_document a.id
      a.verified.should be_false
    end
    
    it "should persist 0 for false" do
      a = Address.new
      a.verified = 0
      CouchPotato.database.save_document! a
      a = CouchPotato.database.load_document a.id
      a.verified.should be_false
    end
    
    it "should persist '1' for true" do
      a = Address.new
      a.verified = '1'
      CouchPotato.database.save_document! a
      a = CouchPotato.database.load_document a.id
      a.verified.should be_true
    end
    
    it "should persist 1 for true" do
      a = Address.new
      a.verified = 1
      CouchPotato.database.save_document! a
      a = CouchPotato.database.load_document a.id
      a.verified.should be_true
    end
    
    it "should leave nil as nil" do
      a = Address.new
      a.verified = nil
      CouchPotato.database.save_document! a
      a = CouchPotato.database.load_document a.id
      a.verified.should be_nil
    end
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
  
  describe "with subclasses" do
    it "should include properties of superclasses" do
      CuckooClock.properties.map(&:name).should include(:time)
      CuckooClock.properties.map(&:name).should include(:cuckoo)
    end
    
    it "should return attributes of superclasses" do
      clock = CuckooClock.new(:time => Time.now, :cuckoo => 'bavarian')
      clock.attributes[:time].should_not == nil
      clock.attributes[:cuckoo].should == 'bavarian'
    end
  end
  
  describe "inspecting an object" do
    let(:comment) do
      comment = Comment.new(:title => 'title')
      comment.instance_eval do
        @_id = "123456abcdef"
        @_rev = "1-654321fedcba"
      end
      comment
    end
    
    it "should not include change-tracking variables" do
      comment.inspect.should_not include('title_was')
    end
    
    it "should include the normal persistent variables" do
      comment.inspect.should include('title: "title"')
    end
    
    it "should include the id" do
      comment.inspect.should include(%Q{_id: "123456abcdef",})
    end
    
    it "should include the revision" do
      comment.inspect.should include(%Q{_rev: "1-654321fedcba",})
    end
    
    it "should return a complete string" do
      # stub to work around (un)sorted hash on different rubies
      comment.stub!(:attributes).and_return([['created_at', ''], ['updated_at', ''], ['title', 'title']])
      comment.inspect.should == %Q{#<Comment _id: "123456abcdef", _rev: "1-654321fedcba", created_at: "", updated_at: "", title: "title">}
    end
    
    it "should include complex datatypes fully inspected" do
      comment.title = {'en' => 'Blog post'}
      comment.inspect.should include('title: {"en"=>"Blog post"}')
      
      comment.title = nil
      comment.inspect.should include('title: nil')
    end
  end
end