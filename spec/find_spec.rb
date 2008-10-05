require File.dirname(__FILE__) + '/spec_helper'

describe "find" do
  before(:each) do
    @comment = Comment.create! :title => 'title'
  end
  
  it "should find by id" do
    Comment.find(@comment.id).should == @comment
  end
  
  it "should assign the id" do
    Comment.find(@comment.id)._id.should == @comment._id
  end
  
  it "should assign the revision" do
    Comment.find(@comment.id)._rev.should == @comment._rev
  end
  
  it "should reurn nil of nothing found" do
    Comment.find(@comment.id.succ).should be_nil
  end
end