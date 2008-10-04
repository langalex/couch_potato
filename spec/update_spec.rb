require File.dirname(__FILE__) + '/spec_helper'

describe "create" do
  before(:each) do
    @comment = Comment.new :title => 'my_title'
    @comment.save!
  end
  
  it "should update the revision" do
    old_rev = @comment._rev
    @comment.save!
    @comment._rev.should_not == old_rev
    @comment._rev.should_not be_nil
  end
  
  it "should not update created at" do
    old_created_at = @comment.created_at
    @comment.save!
    @comment.created_at.should == old_created_at
  end
  
  it "should update updated at" do
    old_updated_at = @comment.updated_at
    @comment.save!
    @comment.updated_at.should > old_updated_at
  end
  
  it "should update the attributes" do
    @comment.title = 'new title'
    @comment.save!
    CouchPotatoe::Persistence.Db.get("#{@comment.id}").title.should == 'new title'
  end
end