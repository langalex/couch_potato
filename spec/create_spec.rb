require File.dirname(__FILE__) + '/spec_helper'

describe "create" do
  describe "succeeds" do
    before(:each) do
      @comment = Comment.new :title => 'my_title'
      @comment.save!
    end

    it "should assign an id" do
      @comment._id.should_not be_nil
    end

    it "should assign a revision" do
      @comment._rev.should_not be_nil
    end

    it "should store the class" do
      CouchPotato::Persistence.Db.get(@comment.id)['ruby_class'].should == 'Comment'
    end

    it "should set created at" do
      DateTime.parse(CouchPotato::Persistence.Db.get(@comment.id)['created_at']).should >= 1.second.ago
      @comment.created_at.should >= 10.seconds.ago
    end

    it "should set updated at" do
      DateTime.parse(CouchPotato::Persistence.Db.get(@comment.id)['updated_at']).should >= 1.second.ago
      @comment.updated_at.should >= 10.seconds.ago
    end
  end
  
  describe "fails" do
    before(:each) do
      CouchPotato::Persistence.Db.delete!
      @comment = Comment.new
      @comment.save
    end

    it "should not assign an id" do
      @comment._id.should be_nil
    end

    it "should not assign a revision" do
      @comment._rev.should be_nil
    end

    it "should not store anything" do
      CouchPotato::Persistence.Db.documents['rows'].should be_empty
    end

    it "should not set created at" do
      @comment.created_at.should be_nil
    end

    it "should set updated at" do
      @comment.updated_at.should be_nil
    end
    
    describe "with bank" do
      it "should raise an exception" do
        lambda {
          @comment.save!
        }.should raise_error
      end
    end
  end
  
end