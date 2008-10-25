require File.dirname(__FILE__) + '/spec_helper'

class OtherComment
  include CouchPotato::Persistence
  
  belongs_to :commenter
end

describe CouchPotato::Persistence::Finder, 'find' do
  before(:each) do
    CouchPotato::Persistence.Db.delete!
  end
  
  it "should find objects with a given attribute value pair" do
    c1 = Comment.create! :title => 'test', :commenter_id => '1'
    c2 = Comment.create! :title => 'test', :commenter_id => '2'
    comments = CouchPotato::Persistence::Finder.new.find Comment, :commenter_id => '1'
    comments.should == [c1]
  end
  
  it "should find items by range" do
    c1 = Comment.create! :title => 'test', :commenter_id => '1'
    c2 = Comment.create! :title => 'test', :commenter_id => '2'
    c3 = Comment.create! :title => 'test', :commenter_id => '3'
    comments = CouchPotato::Persistence::Finder.new.find Comment, :commenter_id => '2'..'3'
    comments.should == [c2, c3]
  end
  
  it "should find items by range and other atributes" do
    c1 = Comment.create! :title => 'test', :commenter_id => '1'
    c2 = Comment.create! :title => 'test', :commenter_id => '2'
    c3 = Comment.create! :title => 'test', :commenter_id => '3'
    c4 = Comment.create! :title => 'test2', :commenter_id => '3'
    comments = CouchPotato::Persistence::Finder.new.find Comment, :commenter_id => '2'..'3', :title => 'test'
    comments.should == [c2, c3]
  end
  
  it "should find objects with multiple given attribute value pair" do
    c1 = Comment.create! :title => 'test', :commenter_id => '1'
    c2 = Comment.create! :title => 'test2', :commenter_id => '1'
    c3 = Comment.create! :title => 'test', :commenter_id => '2'
    comments = CouchPotato::Persistence::Finder.new.find Comment, :commenter_id => '1', :title => 'test'
    comments.should == [c1]
  end
  
  it "should find them when the view has been created already" do
    c1 = Comment.create! :title => 'test', :commenter_id => '1'
    c2 = Comment.create! :title => 'test', :commenter_id => '2'
    CouchPotato::Persistence::Finder.new.find Comment, :commenter_id => '1'
    comments = CouchPotato::Persistence::Finder.new.find Comment, :commenter_id => '1'
    comments.should == [c1]
  end
  
  it "should not find instances of other classes" do
    OtherComment.create! :commenter_id => '1'
    comments = CouchPotato::Persistence::Finder.new.find Comment, :commenter_id => '1'
    comments.should be_empty
  end
  
  it "should update the design document correctly when running multiple finds" do
    CouchPotato::Persistence::Finder.new.find Comment, :commenter_id => '1'
    lambda {
      CouchPotato::Persistence::Finder.new.find Comment, :commenter_id => '1', :title => 'test'
    }.should_not raise_error(RestClient::RequestFailed)
  end
end

describe CouchPotato::Persistence::Finder, 'count' do
  before(:each) do
    CouchPotato::Persistence.Db.delete!
  end
  
  it "should count objects with a given attribute value pair" do
    c1 = Comment.create! :title => 'test', :commenter_id => '1'
    c2 = Comment.create! :title => 'test', :commenter_id => '2'
    CouchPotato::Persistence::Finder.new.count(Comment, :commenter_id => '1').should == 1
  end
  
  it "should count objects with multiple given attribute value pair" do
    c1 = Comment.create! :title => 'test', :commenter_id => '1'
    c2 = Comment.create! :title => 'test2', :commenter_id => '1'
    c3 = Comment.create! :title => 'test', :commenter_id => '2'
    CouchPotato::Persistence::Finder.new.count(Comment, :commenter_id => '1', :title => 'test').should == 1
  end
  
  it "should count them when the view has been created already" do
    c1 = Comment.create! :title => 'test', :commenter_id => '1'
    c2 = Comment.create! :title => 'test', :commenter_id => '2'
    CouchPotato::Persistence::Finder.new.count Comment, :commenter_id => '1'
    CouchPotato::Persistence::Finder.new.count(Comment, :commenter_id => '1').should == 1
  end
  
  it "should not count instances of other classes" do
    OtherComment.create! :commenter_id => '1'
    CouchPotato::Persistence::Finder.new.count(Comment, :commenter_id => '1').should == 0
  end
end