require File.dirname(__FILE__) + '/spec_helper'

describe CouchPotatoe::Persistence::Finder, 'find children' do
  before(:each) do
    CouchPotatoe::Persistence.Db.delete!
  end
  
  it "should find objects with a given type and owner_id" do
    c1 = Comment.create! :title => 'test', :commenter_id => '1'
    c2 = Comment.create! :title => 'test', :commenter_id => '2'
    comment = CouchPotatoe::Persistence::Finder.new.find Comment, :commenter_id => '1'
    comment.should == [c1]
  end
  
  it "should find them when the view has been created already" do
    c1 = Comment.create! :title => 'test', :commenter_id => '1'
    c2 = Comment.create! :title => 'test', :commenter_id => '2'
    CouchPotatoe::Persistence::Finder.new.find Comment, :commenter_id => '1'
    comment = CouchPotatoe::Persistence::Finder.new.find Comment, :commenter_id => '1'
    comment.should == [c1]
  end
end