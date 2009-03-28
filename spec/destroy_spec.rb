require File.dirname(__FILE__) + '/spec_helper'

describe 'destroy' do
  before(:all) do
    recreate_db
  end
  
  before(:each) do
    @comment = Comment.create! :title => 'title'
    @comment_id = @comment.id
    @comment.destroy
  end
  
  it "should unset the id" do
    @comment._id.should be_nil
  end
  
  it "should unset the revision" do
    @comment._rev.should be_nil
  end
  
  it "should remove the document from the database" do
    lambda {
      CouchPotato::Persistence.Db.get(@comment_id).should
    }.should raise_error(RestClient::ResourceNotFound)
  end
  
end