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
  
  def callbacks
    @callbacks ||= []
  end
  
end

describe 'create callbacks' do
  
  before(:each) do
    @recorder = CallbackRecorder.new
  end
  
  describe "successful create" do
    before(:each) do
       @recorder.required_property = 1
    end
    
    it "should call before_validation_on_create" do
      @recorder.save!
      @recorder.callbacks.should include(:before_validation_on_create)
    end
    
    it "should call before_validation_on_save" do
      @recorder.save!
      @recorder.callbacks.should include(:before_validation_on_save)
    end
    
    it "should call before_save" do
      @recorder.save!
      @recorder.callbacks.should include(:before_save)
    end
    
    it "should call after_save" do
      @recorder.save!
      @recorder.callbacks.should include(:after_save)
    end
    
    it "should call before_create" do
      @recorder.save!
      @recorder.callbacks.should include(:before_create)
    end
    
    it "should call after_create" do
      @recorder.save!
      @recorder.callbacks.should include(:after_create)
    end
    
  end
  
  describe "failed create" do
    
    it "should call before_validation_on_create" do
      @recorder.save
      @recorder.callbacks.should include(:before_validation_on_create)
    end
    
    it "should call before_validation_on_save" do
      @recorder.save
      @recorder.callbacks.should include(:before_validation_on_save)
    end
    
    it "should not call before_save" do
      @recorder.save
      @recorder.callbacks.should_not include(:before_save)
    end
    
    it "should not call after_save" do
      @recorder.save
      @recorder.callbacks.should_not include(:after_save)
    end
    
    it "should not call before_create" do
      @recorder.save
      @recorder.callbacks.should_not include(:before_create)
    end
    
    it "should not call after_create" do
      @recorder.save
      @recorder.callbacks.should_not include(:after_create)
    end
    
  end
  
  
end

describe "update callbacks" do
  
  before(:each) do
    @recorder = CallbackRecorder.create! :required_property => 1
    @recorder.callbacks.clear
  end
  
  describe "successful update" do
    
    it "should call before_validation_on_update" do
      @recorder.save!
      @recorder.callbacks.should include(:before_validation_on_update)
    end
    
    it "should call before_validation_on_save" do
      @recorder.save!
      @recorder.callbacks.should include(:before_validation_on_save)
    end
    
    it "should call before_save" do
      @recorder.save!
      @recorder.callbacks.should include(:before_save)
    end
    
    it "should call after_save" do
      @recorder.save!
      @recorder.callbacks.should include(:after_save)
    end
    
    it "should call before_update" do
      @recorder.save!
      @recorder.callbacks.should include(:before_update)
    end
    
    it "should call after_update" do
      @recorder.save!
      @recorder.callbacks.should include(:after_update)
    end
    
  end
  
  describe "failed update" do
    
    before(:each) do
       @recorder.required_property = nil
    end
    
    it "should call before_validation_on_update" do
      @recorder.save
      @recorder.callbacks.should include(:before_validation_on_update)
    end
    
    it "should call before_validation_on_save" do
      @recorder.save
      @recorder.callbacks.should include(:before_validation_on_save)
    end
    
    it "should not call before_save" do
      @recorder.save
      @recorder.callbacks.should_not include(:before_save)
    end
    
    it "should not call after_save" do
      @recorder.save
      @recorder.callbacks.should_not include(:after_save)
    end
    
    it "should not call before_update" do
      @recorder.save
      @recorder.callbacks.should_not include(:before_update)
    end
    
    it "should not call after_update" do
      @recorder.save
      @recorder.callbacks.should_not include(:after_update)
    end
    
  end
  
end

describe "destroy callbacks" do
  before(:each) do
    @recorder = CallbackRecorder.create! :required_property => 1
    @recorder.callbacks.clear
  end
  
  it "should call before_destroy" do
    @recorder.destroy
    @recorder.callbacks.should include(:before_destroy)
  end
  
  it "should call after_destroy" do
    @recorder.destroy
    @recorder.callbacks.should include(:after_destroy)
  end
end