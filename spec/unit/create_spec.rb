require File.dirname(__FILE__) + '/../spec_helper'

describe "create" do
  
  describe "succeeds" do
    before(:each) do
      @comment = Comment.new :title => 'my_title'
      CouchPotato::Database.new(stub('database', :save_doc => {'rev' => '123', 'id' => '456'})).save_document!(@comment)
    end

    it "should assign the id" do
      @comment._id.should == '456'
    end

    it "should assign the revision" do
      @comment._rev.should == '123'
    end

    it "should set created at" do
      @comment.created_at.should >= Time.now - 10
    end

    it "should set updated at" do
      @comment.updated_at.should >= Time.now - 10
    end
  end
  
  describe "fails" do
    before(:each) do
      @comment = Comment.new
      CouchPotato::Database.new(stub('database')).save_document(@comment)
    end

    it "should not assign an id" do
      @comment._id.should be_nil
    end

    it "should not assign a revision" do
      @comment._rev.should be_nil
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