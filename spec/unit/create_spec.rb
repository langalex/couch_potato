require 'spec_helper'

describe "create" do
  
  describe "succeeds" do
    before(:each) do
      Time.zone = nil
    end
    
    def create_comment
      comment = Comment.new :title => 'my_title'
      CouchPotato::Database.new(stub('database', :save_doc => {'rev' => '123', 'id' => '456'}, :info => nil)).save_document!(comment)
      comment
    end

    it "should assign the id" do
      create_comment._id.should == '456'
    end

    it "should assign the revision" do
      create_comment._rev.should == '123'
    end

    it "should set created at in the current time zone" do
      Time.zone = 'Europe/Berlin'
      Timecop.travel 2010, 1, 1, 12 do
        create_comment.created_at.to_s.should == '2010-01-01 12:00:00 +0100'
      end
    end

    it "should set updated at in the current time zone" do
      Time.zone = 'Europe/Berlin'
      Timecop.travel 2010, 1, 1, 12 do
        create_comment.updated_at.to_s.should == '2010-01-01 12:00:00 +0100'
      end
    end
  end
  
  describe "fails" do
    before(:each) do
      @comment = Comment.new
      CouchPotato::Database.new(stub('database', :info => nil)).save_document(@comment)
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