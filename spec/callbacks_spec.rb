require File.dirname(__FILE__) + '/spec_helper'

class CallbackRecorder
  include CouchPotato::Persistence
  
  property :required_property
  
  validates_presence_of :required_property
  
  [:before_validation_on_create,
    :before_validation_on_save, :before_validation_on_update, 
    :before_save, :before_create, :before_create,
    :after_save, :after_create, :after_create,
    :before_update, :after_update,
    :before_destroy, :after_destroy
  ].each do |callback|
    define_method callback do
      callbacks << callback
    end
    self.send callback, callback
  end
  
  attr_accessor :lambda_works
  before_create lambda {|model| model.lambda_works = true}
  
  def callbacks
    @callbacks ||= []
  end
  
end

describe "multiple callbacks at once" do

  class Monkey
    include CouchPotato::Persistence
    attr_accessor :eaten_banana, :eaten_apple
    
    before_create :eat_apple, :eat_banana
    
    private
    
    def eat_banana
      self.eaten_banana = true
    end
    
    def eat_apple
      self.eaten_apple = true
    end
  end
  it "should run all callback methods given to the callback method call" do
    monkey = Monkey.new
    CouchPotato.database.save_document! monkey
    monkey.eaten_banana.should be_true
    monkey.eaten_apple.should be_true
  end
end

describe 'create callbacks' do
  
  before(:each) do
    @recorder = CallbackRecorder.new
    couchrest_database = stub 'couchrest_database', :save_doc => {'id' => '1', 'rev' => '2'}
    @db = CouchPotato::Database.new(couchrest_database)
  end
  
  describe "successful create" do
    before(:each) do
       @recorder.required_property = 1
    end
    
    it "should call before_validation_on_create" do
      @db.save_document! @recorder
      @recorder.callbacks.should include(:before_validation_on_create)
    end
    
    it "should call before_validation_on_save" do
      @db.save_document! @recorder
      @recorder.callbacks.should include(:before_validation_on_save)
    end
    
    it "should call before_save" do
      @db.save_document! @recorder
      @recorder.callbacks.should include(:before_save)
    end
    
    it "should call after_save" do
      @db.save_document! @recorder
      @recorder.callbacks.should include(:after_save)
    end
    
    it "should call before_create" do
      @db.save_document! @recorder
      @recorder.callbacks.should include(:before_create)
    end
    
    it "should call after_create" do
      @db.save_document! @recorder
      @recorder.callbacks.should include(:after_create)
    end
    
  end
  
  describe "failed create" do
    
    it "should call before_validation_on_create" do
      @db.save_document @recorder
      @recorder.callbacks.should include(:before_validation_on_create)
    end
    
    it "should call before_validation_on_save" do
      @db.save_document @recorder
      @recorder.callbacks.should include(:before_validation_on_save)
    end
    
    it "should not call before_save" do
      @db.save_document @recorder
      @recorder.callbacks.should_not include(:before_save)
    end
    
    it "should not call after_save" do
      @db.save_document @recorder
      @recorder.callbacks.should_not include(:after_save)
    end
    
    it "should not call before_create" do
      @db.save_document @recorder
      @recorder.callbacks.should_not include(:before_create)
    end
    
    it "should not call after_create" do
      @db.save_document @recorder
      @recorder.callbacks.should_not include(:after_create)
    end
  end
end

describe "update callbacks" do
  
  before(:each) do
    @recorder = CallbackRecorder.new :required_property => 1
    
    couchrest_database = stub 'couchrest_database', :save_doc => {'id' => '1', 'rev' => '2'}
    @db = CouchPotato::Database.new(couchrest_database)
    @db.save_document! @recorder
    
    @recorder.required_property = 2
    @recorder.callbacks.clear
  end
  
  describe "successful update" do
    
    before(:each) do
      @db.save_document! @recorder
    end
    
    it "should call before_validation_on_update" do
      @recorder.callbacks.should include(:before_validation_on_update)
    end
    
    it "should call before_validation_on_save" do
      @recorder.callbacks.should include(:before_validation_on_save)
    end
    
    it "should call before_save" do
      @recorder.callbacks.should include(:before_save)
    end
    
    it "should call after_save" do
      @recorder.callbacks.should include(:after_save)
    end
    
    it "should call before_update" do
      @recorder.callbacks.should include(:before_update)
    end
    
    it "should call after_update" do
      @recorder.callbacks.should include(:after_update)
    end
    
  end
  
  describe "failed update" do
    
    before(:each) do
       @recorder.required_property = nil
       @db.save_document @recorder
    end
    
    it "should call before_validation_on_update" do
      @recorder.callbacks.should include(:before_validation_on_update)
    end
    
    it "should call before_validation_on_save" do
      @recorder.callbacks.should include(:before_validation_on_save)
    end
    
    it "should not call before_save" do
      @recorder.callbacks.should_not include(:before_save)
    end
    
    it "should not call after_save" do
      @recorder.callbacks.should_not include(:after_save)
    end
    
    it "should not call before_update" do
      @recorder.callbacks.should_not include(:before_update)
    end
    
    it "should not call after_update" do
      @recorder.callbacks.should_not include(:after_update)
    end
    
  end
  
end

describe "destroy callbacks" do
  
  before(:each) do
    @recorder = CallbackRecorder.new :required_property => 1
    couchrest_database = stub 'couchrest_database', :save_doc => {'id' => '1', 'rev' => '2'}, :delete_doc => nil
    @db = CouchPotato::Database.new(couchrest_database)
    @db.save_document! @recorder
    
    @recorder.callbacks.clear
  end
  
  it "should call before_destroy" do
    @db.destroy_document @recorder
    @recorder.callbacks.should include(:before_destroy)
  end
  
  it "should call after_destroy" do
    @db.destroy_document @recorder
    @recorder.callbacks.should include(:after_destroy)
  end
end

describe "lambda callbacks" do
  it "should run the lambda" do
    recorder = CallbackRecorder.new
    recorder.run_callbacks :before_create
    recorder.lambda_works.should be_true
  end
end