require 'spec_helper'

class CallbackRecorder
  include CouchPotato::Persistence
  
  property :required_property
  
  validates_presence_of :required_property
  
  [:before_validation, :before_validation_on_create,
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
  
  view :all, :key  => :required_property
  
  def callbacks
    @callbacks ||= []
  end
  
  private
  
  def method_callback_with_argument(db)
    db.view CallbackRecorder.all
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
    monkey.run_callbacks :create
    monkey.eaten_banana.should be_true
    monkey.eaten_apple.should be_true
  end
end

describe 'create callbacks' do
  
  before(:each) do
    @recorder = CallbackRecorder.new
    couchrest_database = stub 'couchrest_database', :save_doc => {'id' => '1', 'rev' => '2'}, :view => {'rows' => []}, :info => nil
    @db = CouchPotato::Database.new(couchrest_database)
  end
  
  describe "successful create" do
    before(:each) do
       @recorder.required_property = 1
    end
    
    it "should call before_validation" do
      @recorder.valid?
      @recorder.callbacks.should include(:before_validation)
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
    
    it "should call before_validation" do
      @recorder.valid?
      @recorder.callbacks.should include(:before_validation)
    end
    
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
    
    couchrest_database = stub 'couchrest_database', :save_doc => {'id' => '1', 'rev' => '2'}, :view => {'rows' => []}, :info => nil
    @db = CouchPotato::Database.new(couchrest_database)
    @db.save_document! @recorder
    
    @recorder.required_property = 2
    @recorder.callbacks.clear
  end
  
  describe "successful update" do
    
    before(:each) do
      @db.save_document! @recorder
    end
    
    it "should call before_validation" do
      @recorder.callbacks.should include(:before_validation)
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
    
    it "should call before_validation" do
      @recorder.callbacks.should include(:before_validation)
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
    couchrest_database = stub 'couchrest_database', :save_doc => {'id' => '1', 'rev' => '2'}, :delete_doc => nil, :view => {'rows' => []}, :info => nil
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

describe "validation callbacks" do
  class ValidatedUser
    include CouchPotato::Persistence

    property :name
    before_validation :check_name
    validates_presence_of :name

    def check_name
      errors.add(:name, 'should be Paul') unless name == "Paul"
    end
  end

  it "should keep error messages set in custom before_validation filters" do
    user = ValidatedUser.new(:name => "john")
    user.valid?.should == false
    user.errors[:name].should == ["should be Paul"]
  end

  it "should combine the errors from validations and callbacks" do
    user = ValidatedUser.new(:name => nil)
    user.valid?.should == false
    user.errors[:name].any? {|msg| msg =~ /can't be (empty|blank)/ }.should == true
    user.errors[:name].any? {|msg| msg == "should be Paul" }.should == true
    user.errors[:name].size.should == 2
  end

  it "should clear the errors on subsequent calls to valid?" do
    user = ValidatedUser.new(:name => nil)
    user.valid?.should == false
    user.name = 'Paul'
    user.valid?.should == true
    user.errors[:name].should == []
  end
end

describe "validation callbacks and filter halt" do
  class FilterValidationUpdateUser
    include CouchPotato::Persistence

    property :name
    before_validation :check_name
    before_validation_on_update :return_false_from_callback

    def check_name
      errors.add(:name, 'should be Paul') unless name == "Paul"
    end

    def return_false_from_callback
      false
    end
  end

  class FilterValidationCreateUser
    include CouchPotato::Persistence

    property :name
    before_validation :check_name
    before_validation_on_save :return_false_from_callback
    before_validation_on_create :return_false_from_callback

    def check_name
      errors.add(:name, 'should be Paul') unless name == "Paul"
    end

    def return_false_from_callback
      false
    end
  end

  class FilterSaveUpdateUser
    include CouchPotato::Persistence

    property :name
    before_update :return_false_from_callback

    def return_false_from_callback
      false
    end
  end

  class FilterSaveCreateUser
    include CouchPotato::Persistence

    property :name
    before_save :return_false_from_callback
    before_create :return_false_from_callback

    def return_false_from_callback
      false
    end
  end

  before(:each) do
    recreate_db
    @db = CouchPotato.database
  end

  it "should keep error messages set in custom before_validation if an update filter returns false" do
    @user = FilterValidationUpdateUser.new(:name => "Paul")
    @db.save_document(@user).should == true
    @user.name = 'Bert'
    @db.save_document(@user).should == false
  end

  it "should keep error messages set in custom before_validation if a create filter returns false" do
    @user = FilterValidationCreateUser.new(:name => "Bert")
    @db.save_document(@user).should == false
  end

  it "should return false on saving a document when a before update filter returned false" do
    @user = FilterSaveUpdateUser.new(:name => "Paul")
    @db.save_document(@user).should == true
    @user.name = 'Bert'
    @db.save_document(@user).should == false
  end

  it "should return false on saving a document when a before save or before create filter returned false" do
    @user = FilterSaveCreateUser.new(:name => "Bert")
    @db.save_document(@user).should == false
  end

end
