require File.dirname(__FILE__) + '/spec_helper'

class OtherComment
  include CouchPotato::Persistence
  
  belongs_to :commenter
end

describe CouchPotato::Persistence::Finder, 'find children' do
  before(:each) do
    CouchPotato::Persistence.Db.delete!
  end
  
  it "should find objects with a given type and owner_id" do
    c1 = Comment.create! :title => 'test', :commenter_id => '1'
    c2 = Comment.create! :title => 'test', :commenter_id => '2'
    comment = CouchPotato::Persistence::Finder.new.find Comment, :commenter_id => '1'
    comment.should == [c1]
  end
  
  it "should find them when the view has been created already" do
    c1 = Comment.create! :title => 'test', :commenter_id => '1'
    c2 = Comment.create! :title => 'test', :commenter_id => '2'
    CouchPotato::Persistence::Finder.new.find Comment, :commenter_id => '1'
    comment = CouchPotato::Persistence::Finder.new.find Comment, :commenter_id => '1'
    comment.should == [c1]
  end
  
  it "should not find instances of other classes" do
    OtherComment.create! :commenter_id => '1'
    comment = CouchPotato::Persistence::Finder.new.find Comment, :commenter_id => '1'
    comment.should be_empty
  end
end