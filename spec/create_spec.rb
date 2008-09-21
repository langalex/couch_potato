require File.dirname(__FILE__) + '/spec_helper'

describe "create" do
  before(:each) do
    @comment = Comment.new :title => 'my_title'
    @comment.save!
  end
  
  it "should assign an id an object" do
    @comment._id.should_not be_nil
  end
  
  it "should assign a revision" do
    @comment._rev.should_not be_nil
  end
  
  it "should store the class" do
    CouchPotatoe::Persistence.Db.get("#{@comment.id}").class.should == Comment
  end
  
  it "should store the properties" do
    CouchPotatoe::Persistence.Db.get("#{@comment.id}").title.should == 'my_title'
  end
  
  it "should set created at" do
    CouchPotatoe::Persistence.Db.get("#{@comment.id}").created_at.should >= 1.second.ago
  end
  
  it "should set updated at" do
    CouchPotatoe::Persistence.Db.get("#{@comment.id}").updated_at.should >= 1.second.ago
  end
end