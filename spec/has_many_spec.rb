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
  
  it "should create child objects" do
    @commenter.save!
    @commenter.comments.create(:title => 'my title')
    @commenter = Commenter.find @commenter._id
    @commenter.comments.first.class.should == Comment
    @commenter.comments.first.title.should == 'my title'
  end
  
  it "should create! child objects" do
    @commenter.save!
    @commenter.comments.create!(:title => 'my title')
    @commenter = Commenter.find @commenter._id
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
  
  describe "destroying" do
    
    class AdminComment
      include CouchPotato::Persistence
      belongs_to :admin
    end
    
    class AdminFriend
      include CouchPotato::Persistence
      belongs_to :admin
    end
    
    class Admin
      include CouchPotato::Persistence
      has_many :admin_comments, :stored => :separately, :dependent => :destroy
      has_many :admin_friends, :stored => :separately
    end
    
    it "should destroy all dependent objects" do
      admin = Admin.create!
      comment = admin.admin_comments.create!
      id = comment._id
      admin.destroy
      lambda {
        CouchPotato::Persistence.Db.get(id).should
      }.should raise_error(RestClient::ResourceNotFound)
    end

    it "should nullify independent objects" do
      admin = Admin.create!
      friend = admin.admin_friends.create!
      id = friend._id
      admin.destroy
      AdminFriend.get(id).admin.should be_nil
    end
  end
end