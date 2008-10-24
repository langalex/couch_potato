require File.dirname(__FILE__) + '/spec_helper'

describe CouchPotato::Versioning do
  class Document
    include CouchPotato::Persistence
    include CouchPotato::Versioning
    
    property :title
    validates_presence_of :title
  end
  
  class ConditionDocument
    attr_accessor :new_version
    include CouchPotato::Persistence
    include CouchPotato::Versioning
    set_version_condition lambda {|doc| doc.new_version}
    
    property :title
    validates_presence_of :title
  end
  
  before(:each) do
    CouchPotato::Persistence.Db.delete!
  end
  
  describe "create" do
    it "should not create a version" do
      Document.create! :title => 'first doc'
      CouchPotato::Persistence.Db.documents['rows'].size.should == 1
    end
    
    it "should set version to 1" do
      Document.create!(:title => 'first doc').version.should == 1
    end
  end
  
  describe "save" do
    it "should create a new version" do
      doc = Document.create! :title => 'first doc'
      doc.title = 'new title'
      doc.save!
      CouchPotato::Persistence.Db.documents['rows'].size.should == 2
    end
    
    it "should store the old attributes in the old version" do
      doc = Document.create! :title => 'first doc'
      doc.title = 'new title'
      doc.save!
      CouchPotato::Persistence.Db.get(
        CouchPotato::Persistence.Db.documents['rows'].select{|row| row['id'] != doc._id}.first['id']
      )['title'].should == 'first doc'
    end
    
    it "should store the old version number in the old version" do
      doc = Document.create! :title => 'first doc'
      doc.title = 'new title'
      id = doc._id
      doc.save!
      CouchPotato::Persistence.Db.get(
        CouchPotato::Persistence.Db.documents['rows'].select{|row| row['id'] != doc._id}.first['id']
      )['version'].should == 1
    end
    
    it "should store the new attributes in the new version" do
      doc = Document.create! :title => 'first doc'
      doc.title = 'new title'
      doc.save!
      CouchPotato::Persistence.Db.get(doc._id)['title'].should == 'new title'
    end
    
    it "should increase the version" do
      doc = Document.create! :title => 'first doc'
      doc.title = 'new title'
      doc.save!
      CouchPotato::Persistence.Db.get(doc._id)['version'].should == 2
    end
    
    it "should not create a new version if condition not met" do
      doc = ConditionDocument.create! :title => 'first doc'
      doc.new_version = false
      doc.title = 'new title'
      doc.save!
      CouchPotato::Persistence.Db.documents['rows'].size.should == 1
    end
    
    it "should not increase the version if condition not met" do
      doc = ConditionDocument.create! :title => 'first doc'
      doc.new_version = false
      doc.title = 'new title'
      doc.save!
      CouchPotato::Persistence.Db.get(doc._id)['version'].should == 1
    end
    
    it "should create a new version if condition met" do
      doc = ConditionDocument.create! :title => 'first doc'
      doc.new_version = true
      doc.title = 'new title'
      doc.save!
      CouchPotato::Persistence.Db.documents['rows'].size.should == 2
    end
    
    it "should increase the version if condition met" do
      doc = ConditionDocument.create! :title => 'first doc'
      doc.new_version = true
      doc.title = 'new title'
      doc.save!
      CouchPotato::Persistence.Db.get(doc._id)['version'].should == 2
    end
  end
  
  it "should load a specific version" do
    doc = Document.create! :title => 'first doc'
    doc.title = 'new title'
    doc.save!
    doc.versions(1).version.should == 1
  end
  
  it "should load all versions" do
    doc = Document.create! :title => 'first doc'
    doc.title = 'new title'
    doc.save!
    doc.title = 'even newer title'
    doc.save!
    doc.versions.map(&:version).should == [1, 2, 3]
  end
  
  it "should load the only version" do
    doc = Document.create! :title => 'first doc'
    doc.versions.map(&:version).should == [1]
  end
  
  it "should load version 1" do
    doc = Document.create! :title => 'first doc'
    doc.versions(1).version.should == 1
  end
  
  it "should not find versions of other instances" do
    doc = Document.create! :title => 'first doc'
    doc.title = 'new title'
    doc.save!
    
    doc2 = Document.create! :title => 'first doc2'
    doc2.title = 'new title2'
    doc2.save!
    
    doc.versions.map(&:title).should == ['first doc', 'new title']
  end
  
end