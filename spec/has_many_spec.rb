require File.dirname(__FILE__) + '/spec_helper'

describe 'has_many' do
  before(:each) do
    @user = User.new
  end
  
  it "should build child objects" do
    @user.comments.build(:title => 'my title')
    @user.comments.first.class.should == Comment
    @user.comments.first.title.should == 'my title'
  end
  
  it "should add child objects" do
    @user.comments << Comment.new(:title => 'my title')
    @user.comments.first.class.should == Comment
    @user.comments.first.title.should == 'my title'
  end
  
  it "should persist child objects" do
    @user.comments.build(:title => 'my title')
    @user.save!
    @user.reload
    @user.comments.first.class.should == Comment
    @user.comments.first.title.should == 'my title'
  end
end