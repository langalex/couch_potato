require 'spec_helper'

describe "create" do
  
  describe "succeeds" do
    before(:each) do
      Time.zone = nil
    end
    
    def create_comment
      comment = Comment.new :title => 'my_title'
      CouchPotato::Database.new(double('database', :save_doc => {'rev' => '123', 'id' => '456'}, :info => nil)).save_document!(comment)
      comment
    end

    it "should assign the id" do
      expect(create_comment._id).to eq('456')
    end

    it "should assign the revision" do
      expect(create_comment._rev).to eq('123')
    end

    it "should set created at in the current time zone" do
      Time.zone = 'Europe/Berlin'
      Timecop.travel Time.zone.parse('2010-01-01 12:00 +0100') do
        expect(create_comment.created_at.to_s).to eq('2010-01-01 12:00:00 +0100')
      end
    end

    it "should set updated at in the current time zone" do
      Time.zone = 'Europe/Berlin'
      Timecop.travel Time.zone.parse('2010-01-01 12:00 +0100') do
        expect(create_comment.updated_at.to_s).to eq('2010-01-01 12:00:00 +0100')
      end
    end
  end
  
  describe "fails" do
    before(:each) do
      @comment = Comment.new
      CouchPotato::Database.new(double('database', :info => nil)).save_document(@comment)
    end

    it "should not assign an id" do
      expect(@comment._id).to be_nil
    end

    it "should not assign a revision" do
      expect(@comment._rev).to be_nil
    end

    it "should not set created at" do
      expect(@comment.created_at).to be_nil
    end

    it "should set updated at" do
      expect(@comment.updated_at).to be_nil
    end
    
    describe "with bank" do
      it "should raise an exception" do
        expect {
          @comment.save!
        }.to raise_error
      end
    end
  end
end