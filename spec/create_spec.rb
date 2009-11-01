require File.dirname(__FILE__) + '/spec_helper'

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
  end
  describe "fails" do
    it "should not store anything" do
      @comment = Comment.new
      CouchPotato.database.save_document @comment
      CouchPotato.couchrest_database.documents['rows'].should be_empty
    end
  end
end

