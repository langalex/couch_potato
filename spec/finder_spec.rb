require File.dirname(__FILE__) + '/spec_helper'

class OtherComment
  include CouchPotato::Persistence
  
  belongs_to :commenter
end

describe CouchPotato::Persistence::Finder, 'find children' do
  before(:each) do
    CouchPotato::Persistence.Db.delete!
  end
  
  it "should find objects with a given attribute value pair" do
    c1 = Comment.create! :title => 'test', :commenter_id => '1'
    c2 = Comment.create! :title => 'test', :commenter_id => '2'
    comments = CouchPotato::Persistence::Finder.new.find Comment, :commenter_id => '1'
    comments.should == [c1]
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
end