require File.dirname(__FILE__) + '/spec_helper'

describe "find" do
  it "should find by id" do
    comment = Comment.create! :title => 'title'
    Comment.find(comment.id).should == comment
  end
end