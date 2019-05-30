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

    def assert_respond_to(receiver, method)
      expect(receiver).to respond_to(method)
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
        expect(@model.to_partial_path).to eq('active_comments/active_comment')
      end
    end

    describe "#persisted?" do
      it "should return false if it is a new document " do
        expect(@model).not_to be_persisted
      end

      it "should be true if it was saved" do
        @comment = ActiveComment.new(:name => 'Thilo', :email => 'test@local.host')
        CouchPotato.database.save_document! @comment
        expect(@comment).to be_persisted
      end
    end

    describe "#to_key" do
      it "should return nil if the document was not persisted" do
        expect(@model.to_key).to be_nil
      end

      it "should return the id of the document if it was persisted" do
        @comment = ActiveComment.new(:name => 'Thilo', :email => 'test@local.host')
        CouchPotato.database.save_document! @comment
        expect(@comment.to_key).to eq([@comment.id])
      end
    end


    describe "#errors" do
      it "should return a single error as array" do
        @model.valid?
        expect(@model.errors[:name]).to be_kind_of(Array)
      end

      it "should return multiple errors as array" do
        @model.valid?
        expect(@model.errors[:email].size).to eq(2)
      end

      it "should return no error as an empty array" do
        expect(@model.errors[:name]).to eq([])
      end

      it "should be able to be Marshal.dump'ed" do
        expect { Marshal.dump(@model.errors) }.not_to raise_error
      end
    end

    describe "#destroyed" do
      it "should return destroyed if the object is deleted" do
        @model._deleted = true
        expect(@model).to be_destroyed
      end

      it "should not return destroyed if it's not deleted" do
        expect(@model).not_to be_destroyed
      end
    end

    def assert(boolean, message = '')
      boolean || raise(message)
    end

    def assert_kind_of(klass, object)
      expect(object).to be_a(klass)
    end
  end

rescue LoadError
  STDERR.puts "WARNING: active_model gem not installed. Not running ActiveModel specs."
end
