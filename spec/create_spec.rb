require File.dirname(__FILE__) + '/spec_helper'

describe "create" do
  before(:all) do
    recreate_db
  end
  describe "succeeds" do
    it "should store the class" do
      @comment = Comment.new :title => 'my_title'
      @comment.save!
      CouchPotato::Persistence.Db.get(@comment.id)['ruby_class'].should == 'Comment'
    end
  end
  describe "fails" do
    it "should not store anything" do
      @comment = Comment.new
      @comment.save
      CouchPotato::Persistence.Db.documents['rows'].should be_empty
    end
  end
end

