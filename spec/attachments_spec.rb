require 'spec_helper'

describe CouchPotato, 'attachments' do
  it "should persist an attachment" do
    comment = Comment.new :title => 'nil'
    comment._attachments['body'] = {'data' => 'a useful comment', 'content_type' => 'text/plain'}
    CouchPotato.database.save! comment
    CouchPotato.couchrest_database.fetch_attachment(comment.to_hash, 'body').to_s.should == 'a useful comment'
  end
  
  it "should give me information about the attachments of a document" do
    comment = Comment.new :title => 'nil'
    comment._attachments = {'body' => {'data' => 'a useful comment', 'content_type' => 'text/plain'}}
    CouchPotato.database.save! comment
    comment_reloaded = CouchPotato.database.load comment.id
    comment_reloaded._attachments["body"].should include({"content_type" => "text/plain", "stub" => true, "length" => 16})
  end
  
  it "should have an empty array for a new object" do
    Comment.new._attachments.should == {}
  end
  
end
