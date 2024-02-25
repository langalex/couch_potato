require 'spec_helper'

describe "create" do
  before(:each) do
    recreate_db
  end

  describe "succeeds" do
    it "should store the class" do
      @comment = Comment.new :title => 'my_title'
      CouchPotato.database.save_document! @comment
      expect(CouchPotato.couchrest_database.get(@comment.id).send(JSON.create_id)).to eq('Comment')
    end

    it "should persist a given created_at" do
      @comment = Comment.new :created_at => Time.parse('2010-01-02 12:34:48 +0000'), :title => '-'
      CouchPotato.database.save_document! @comment
      expect(CouchPotato.couchrest_database.get(@comment.id).created_at).to eq(Time.parse('2010-01-02 12:34:48 +0000'))
    end

    it "should persist a given updated_at" do
      @comment = Comment.new :updated_at => Time.parse('2010-01-02 12:34:48 +0000'), :title => '-'
      CouchPotato.database.save_document! @comment
      expect(CouchPotato.couchrest_database.get(@comment.id).updated_at).to eq(Time.parse('2010-01-02 12:34:48 +0000'))
    end
  end

  describe "fails" do
    it "should not store anything" do
      @comment = Comment.new
      CouchPotato.database.save_document @comment
      expect(CouchPotato.couchrest_database.documents['rows']).to be_empty
    end
  end

  describe "multi-db" do
    let(:test_dbs) do 
      ['comment_a', 'comment_b', 'comment_c'].map do |name|
        if ENV['DATABASE']
          uri = URI.parse(ENV['DATABASE'])
          uri.path  = "/#{name}"
          uri.to_s
        else
          name
        end
      end
    end

    before(:each) do
      test_dbs.each { |db_name| CouchPotato.couchrest_database_for_name(db_name).recreate! }
    end

    it "should create documents in multiple dbs" do
      test_dbs.each do |db_name|
        @comment = Comment.new(:title => 'my_title')
        CouchPotato.with_database(db_name) do |couch|
          couch.save_document! @comment
        end
        expect(CouchPotato.couchrest_database_for_name(db_name).get(@comment.id).send(JSON.create_id)).to eq('Comment')
      end
    end
  end
end
