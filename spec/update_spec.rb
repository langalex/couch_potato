require "spec_helper"

describe "create" do
  before(:all) do
    recreate_db
  end

  before(:each) do
    @comment = Comment.new title: "my_title", updated_at: Time.now - 100
    CouchPotato.database.save_document! @comment
  end

  it "should update the revision" do
    old_rev = @comment._rev
    @comment.title = "xyz"
    CouchPotato.database.save_document! @comment
    expect(@comment._rev).not_to eq(old_rev)
    expect(@comment._rev).not_to be_nil
  end

  it "should not update created at" do
    old_created_at = @comment.created_at
    @comment.title = "xyz"
    CouchPotato.database.save_document! @comment
    expect(@comment.created_at).to eq(old_created_at)
  end

  it "should update updated at" do
    old_updated_at = @comment.updated_at
    @comment.title = "xyz"
    CouchPotato.database.save_document! @comment
    expect(@comment.updated_at).to be > old_updated_at
  end

  it "should update the attributes" do
    @comment.title = "new title"
    CouchPotato.database.save_document! @comment
    expect(CouchPotato.couchrest_database.get("#{@comment.id}").title).to eq("new title")
  end
end
