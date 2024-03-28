require "spec_helper"

describe "destroy" do
  before(:all) do
    recreate_db
  end

  before(:each) do
    @comment = Comment.new title: "title"
    CouchPotato.database.save_document! @comment
    @comment_id = @comment.id
    CouchPotato.database.destroy_document @comment
  end

  it "should unset the id" do
    expect(@comment._id).to be_nil
  end

  it "should unset the revision" do
    expect(@comment._rev).to be_nil
  end

  it "should remove the document from the database" do
    expect {
      CouchPotato.couchrest_database.get!(@comment_id)
    }.to raise_error(CouchRest::NotFound)
  end
end
