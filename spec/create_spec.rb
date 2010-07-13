require 'spec_helper'

describe "create" do
  before(:all) do
    recreate_db
  end
  describe "succeeds" do
    it "should store the class" do
      @comment = Comment.new :title => 'my_title'
      CouchPotato.database.save_document! @comment
      CouchPotato.couchrest_database.get(@comment.id).send(JSON.create_id).should == 'Comment'
    end
    
    it "should persist a given created_at" do
      @comment = Comment.new :created_at => Time.parse('2010-01-02 12:34:48 +0000'), :title => '-'
      CouchPotato.database.save_document! @comment
      CouchPotato.couchrest_database.get(@comment.id).created_at.should == Time.parse('2010-01-02 12:34:48 +0000')
    end
    
    it "should persist a given updated_at" do
      @comment = Comment.new :updated_at => Time.parse('2010-01-02 12:34:48 +0000'), :title => '-'
      CouchPotato.database.save_document! @comment
      CouchPotato.couchrest_database.get(@comment.id).updated_at.should == Time.parse('2010-01-02 12:34:48 +0000')
    end
  end
  describe "fails" do
    it "should not store anything" do
      @comment = Comment.new
      CouchPotato.database.save_document @comment
      CouchPotato.couchrest_database.documents['rows'].should be_empty
    end
  end
end

