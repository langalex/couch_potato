require 'spec_helper'

describe Comment do
  it "Should not be valid when newly created" do
    comment = Comment.new
    comment.should_not be_valid
  end

  it "should be valid with a title" do
    comment = Comment.new :title => "I am valid"
    comment.should be_valid
  end

end
