require 'spec_helper'

begin
  require 'active_model'

  describe 'ActiveModel conformance of couch potato objects' do
    include ActiveModel::Lint::Tests

    instance_methods.sort.select{|method| method.to_s.scan(/^test_/).first}.each do |method|
      it "should #{method.to_s.sub(/^test_/, '').gsub('_', ' ')}" do
        send method
      end
    end

    def assert_equal(one, other)
      expect(one).to equal(other)
    end

    class ActiveComment
      include CouchPotato::Persistence
      property :name
      property :email
      validates_presence_of :name, :email
      validates_format_of :email, :with => /.+@.+/
    end

    before(:each) do
      @model = ActiveComment.new
    end

    describe '#to_partial_path' do
      it 'returns a path based on the class name' do
        @model.to_partial_path.should == 'active_comments/active_comment'
      end
    end

    describe "#persisted?" do
      it "should return false if it is a new document " do
        @model.should_not be_persisted
      end

      it "should be true if it was saved" do
        @comment = ActiveComment.new(:name => 'Thilo', :email => 'test@local.host')
        CouchPotato.database.save_document! @comment
        @comment.should be_persisted
      end
    end

    describe "#to_key" do
      it "should return nil if the document was not persisted" do
        @model.to_key.should be_nil
      end

      it "should return the id of the document if it was persisted" do
        @comment = ActiveComment.new(:name => 'Thilo', :email => 'test@local.host')
        CouchPotato.database.save_document! @comment
        @comment.to_key.should == [@comment.id]
      end
    end


    describe "#errors" do
      it "should return a single error as array" do
        @model.valid?
        @model.errors[:name].should be_kind_of(Array)
      end

      it "should return multiple errors as array" do
        @model.valid?
        @model.errors[:email].size.should == 2
      end

      it "should return no error as an empty array" do
        @model.errors[:name].should == []
      end

      it "should be able to be Marshal.dump'ed" do
        lambda { Marshal.dump(@model.errors) }.should_not raise_error
      end
    end

    describe "#destroyed" do
      it "should return destroyed if the object is deleted" do
        @model._deleted = true
        @model.should be_destroyed
      end

      it "should not return destroyed if it's not deleted" do
        @model.should_not be_destroyed
      end
    end

    def assert(boolean, message = '')
      boolean || raise(message)
    end

    def assert_kind_of(klass, object)
      object.should be_a(klass)
    end
  end

rescue LoadError
  STDERR.puts "WARNING: active_model gem not installed. Not running ActiveModel specs."
end
