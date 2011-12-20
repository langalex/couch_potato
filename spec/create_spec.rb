require 'spec_helper'

describe "create" do
  before(:each) do
    recreate_db
  end

  describe "succeeds" do
    it "should store the class" do
      @comment = Comment.new :title => 'my_title'
      CouchPotato.database.save_document! @comment
      CouchPotato.couchrest_database.get(@comment.id).send(JSON.create_id).should == 'Comment'
    end

    it "should persist a given created_at" do
      @comment = Comment.new :created_at => Time.parse('2010-01-02 12:34:48 +0000'), :title => '-'
      CouchPotato.database.save_document! @comment
      CouchPotato.couchrest_database.get(@comment.id).created_at.should == Time.parse('2010-01-02 12:34:48 +0000')
    end

    it "should persist a given updated_at" do
      @comment = Comment.new :updated_at => Time.parse('2010-01-02 12:34:48 +0000'), :title => '-'
      CouchPotato.database.save_document! @comment
      CouchPotato.couchrest_database.get(@comment.id).updated_at.should == Time.parse('2010-01-02 12:34:48 +0000')
    end
  end

  describe "fails" do
    it "should not store anything" do
      @comment = Comment.new
      CouchPotato.database.save_document @comment
      CouchPotato.couchrest_database.documents['rows'].should be_empty
    end
  end

  describe "multi-db" do
    TEST_DBS = ['comment_a', 'comment_b', 'comment_c']

    before(:each) do
      TEST_DBS.each { |db_name| CouchPotato.couchrest_database_for_name(db_name).recreate! }
    end

    it "should create documents in multiple dbs" do
      TEST_DBS.each do |db_name|
        @comment = Comment.new(:title => 'my_title')
        CouchPotato.with_database(db_name) do |couch|
          couch.save_document! @comment
        end
        CouchPotato.couchrest_database_for_name(db_name).get(@comment.id).send(JSON.create_id).should == 'Comment'
      end
    end
  end
end
