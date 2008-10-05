require File.dirname(__FILE__) + '/spec_helper'

describe 'has_many stored inline' do
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
    @user =  User.find @user._id
    @user.comments.first.class.should == Comment
    @user.comments.first.title.should == 'my title'
  end
end

describe 'has_many stored separately' do
  before(:each) do
    @commenter = Commenter.new
  end
  
  it "should build child objects" do
    @commenter.comments.build(:title => 'my title')
    @commenter.comments.first.class.should == Comment
    @commenter.comments.first.title.should == 'my title'
  end
  
  it "should add child objects" do
    @commenter.comments << Comment.new(:title => 'my title')
    @commenter.comments.first.class.should == Comment
    @commenter.comments.first.title.should == 'my title'
  end
  
  it "should persist child objects" do
    @commenter.comments.build(:title => 'my title')
    @commenter.save!
    @commenter = Commenter.find @commenter._id
    @commenter.comments.first.class.should == Comment
    @commenter.comments.first.title.should == 'my title'
  end
end