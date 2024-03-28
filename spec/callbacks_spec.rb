require "spec_helper"

class CallbackRecorderWithNoRequiredProperties
  include CouchPotato::Persistence

  property :required_property

  [:before_validation, :before_validation_on_create,
    :before_validation_on_save, :before_validation_on_update,
    :before_save, :before_create, :before_create,
    :after_save, :after_create, :after_create,
    :before_update, :after_update,
    :before_destroy, :after_destroy].each do |callback|
    define_method callback do
      callbacks << callback
    end
    send callback, callback
  end

  view :all, key: :required_property

  def callbacks
    @callbacks ||= []
  end

  private

  def method_callback_with_argument(db)
    db.view CallbackRecorder.all
  end
end

class CallbackRecorder < CallbackRecorderWithNoRequiredProperties
  validates_presence_of :required_property
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
    expect(monkey.eaten_banana).to be_truthy
    expect(monkey.eaten_apple).to be_truthy
  end
end

describe "create callbacks" do
  before(:each) do
    @recorder = CallbackRecorder.new
    couchrest_database = double "couchrest_database", save_doc: {"id" => "1", "rev" => "2"}, view: {"rows" => []}, info: nil
    @db = CouchPotato::Database.new(couchrest_database)
  end

  describe "successful create" do
    before(:each) do
      @recorder.required_property = 1
    end

    it "should call before_validation" do
      @recorder.valid?
      expect(@recorder.callbacks).to include(:before_validation)
    end

    it "should call before_validation_on_create" do
      @db.save_document! @recorder
      expect(@recorder.callbacks).to include(:before_validation_on_create)
    end

    it "should call before_validation_on_save" do
      @db.save_document! @recorder
      expect(@recorder.callbacks).to include(:before_validation_on_save)
    end

    it "should call before_save" do
      @db.save_document! @recorder
      expect(@recorder.callbacks).to include(:before_save)
    end

    it "should call after_save" do
      @db.save_document! @recorder
      expect(@recorder.callbacks).to include(:after_save)
    end

    it "should call before_create" do
      @db.save_document! @recorder
      expect(@recorder.callbacks).to include(:before_create)
    end

    it "should call after_create" do
      @db.save_document! @recorder
      expect(@recorder.callbacks).to include(:after_create)
    end
  end

  describe "successful create with no changes (object not dirty)" do
    before(:each) do
      @recorder = CallbackRecorderWithNoRequiredProperties.new
    end

    it "should call before_validation" do
      @recorder.valid?
      expect(@recorder.callbacks).to include(:before_validation)
    end

    it "should call before_validation_on_create" do
      @db.save_document! @recorder
      expect(@recorder.callbacks).to include(:before_validation_on_create)
    end

    it "should call before_validation_on_save" do
      @db.save_document! @recorder
      expect(@recorder.callbacks).to include(:before_validation_on_save)
    end

    it "should call before_save" do
      @db.save_document! @recorder
      expect(@recorder.callbacks).to include(:before_save)
    end

    it "should call after_save" do
      @db.save_document! @recorder
      expect(@recorder.callbacks).to include(:after_save)
    end

    it "should call before_create" do
      @db.save_document! @recorder
      expect(@recorder.callbacks).to include(:before_create)
    end

    it "should call after_create" do
      @db.save_document! @recorder
      expect(@recorder.callbacks).to include(:after_create)
    end
  end

  describe "failed create" do
    it "should call before_validation" do
      @recorder.valid?
      expect(@recorder.callbacks).to include(:before_validation)
    end

    it "should call before_validation_on_create" do
      @db.save_document @recorder
      expect(@recorder.callbacks).to include(:before_validation_on_create)
    end

    it "should call before_validation_on_save" do
      @db.save_document @recorder
      expect(@recorder.callbacks).to include(:before_validation_on_save)
    end

    it "should not call before_save" do
      @db.save_document @recorder
      expect(@recorder.callbacks).not_to include(:before_save)
    end

    it "should not call after_save" do
      @db.save_document @recorder
      expect(@recorder.callbacks).not_to include(:after_save)
    end

    it "should not call before_create" do
      @db.save_document @recorder
      expect(@recorder.callbacks).not_to include(:before_create)
    end

    it "should not call after_create" do
      @db.save_document @recorder
      expect(@recorder.callbacks).not_to include(:after_create)
    end
  end
end

describe "update callbacks" do
  before(:each) do
    @recorder = CallbackRecorder.new required_property: 1

    couchrest_database = double "couchrest_database", save_doc: {"id" => "1", "rev" => "2"}, view: {"rows" => []}, info: nil
    @db = CouchPotato::Database.new(couchrest_database)
    @db.save_document! @recorder

    @recorder.callbacks.clear
  end

  describe "successful update" do
    before(:each) do
      @recorder.required_property = 2
      @db.save_document! @recorder
    end

    it "should call before_validation" do
      expect(@recorder.callbacks).to include(:before_validation)
    end

    it "should call before_validation_on_update" do
      expect(@recorder.callbacks).to include(:before_validation_on_update)
    end

    it "should call before_validation_on_save" do
      expect(@recorder.callbacks).to include(:before_validation_on_save)
    end

    it "should call before_save" do
      expect(@recorder.callbacks).to include(:before_save)
    end

    it "should call after_save" do
      expect(@recorder.callbacks).to include(:after_save)
    end

    it "should call before_update" do
      expect(@recorder.callbacks).to include(:before_update)
    end

    it "should call after_update" do
      expect(@recorder.callbacks).to include(:after_update)
    end
  end

  describe "successful update with no changes (object is not dirty)" do
    before(:each) do
      @db.save_document! @recorder
    end

    it "should call before_validation" do
      expect(@recorder.callbacks).to include(:before_validation)
    end

    it "should call before_validation_on_update" do
      expect(@recorder.callbacks).to include(:before_validation_on_update)
    end

    it "should call before_validation_on_save" do
      expect(@recorder.callbacks).to include(:before_validation_on_save)
    end

    it "should call before_save" do
      expect(@recorder.callbacks).to include(:before_save)
    end

    it "should call after_save" do
      expect(@recorder.callbacks).to include(:after_save)
    end

    it "should call before_update" do
      expect(@recorder.callbacks).to include(:before_update)
    end

    it "should call after_update" do
      expect(@recorder.callbacks).to include(:after_update)
    end
  end

  describe "failed update" do
    before(:each) do
      @recorder.required_property = nil
      @db.save_document @recorder
    end

    it "should call before_validation" do
      expect(@recorder.callbacks).to include(:before_validation)
    end

    it "should call before_validation_on_update" do
      expect(@recorder.callbacks).to include(:before_validation_on_update)
    end

    it "should call before_validation_on_save" do
      expect(@recorder.callbacks).to include(:before_validation_on_save)
    end

    it "should not call before_save" do
      expect(@recorder.callbacks).not_to include(:before_save)
    end

    it "should not call after_save" do
      expect(@recorder.callbacks).not_to include(:after_save)
    end

    it "should not call before_update" do
      expect(@recorder.callbacks).not_to include(:before_update)
    end

    it "should not call after_update" do
      expect(@recorder.callbacks).not_to include(:after_update)
    end
  end
end

describe "destroy callbacks" do
  before(:each) do
    @recorder = CallbackRecorder.new required_property: 1
    couchrest_database = double "couchrest_database", save_doc: {"id" => "1", "rev" => "2"}, delete_doc: nil, view: {"rows" => []}, info: nil
    @db = CouchPotato::Database.new(couchrest_database)
    @db.save_document! @recorder

    @recorder.callbacks.clear
  end

  it "should call before_destroy" do
    @db.destroy_document @recorder
    expect(@recorder.callbacks).to include(:before_destroy)
  end

  it "should call after_destroy" do
    @db.destroy_document @recorder
    expect(@recorder.callbacks).to include(:after_destroy)
  end
end

describe "validation callbacks" do
  class ValidatedUser
    include CouchPotato::Persistence

    property :name
    before_validation :check_name
    validates_presence_of :name

    def check_name
      errors.add(:name, "should be Paul") unless name == "Paul"
    end
  end

  it "should keep error messages set in custom before_validation filters" do
    user = ValidatedUser.new(name: "john")
    expect(user.valid?).to eq(false)
    expect(user.errors[:name]).to eq(["should be Paul"])
  end

  it "should combine the errors from validations and callbacks" do
    user = ValidatedUser.new(name: nil)
    expect(user.valid?).to eq(false)
    expect(user.errors[:name].any? { |msg| msg =~ /can't be (empty|blank)/ }).to eq(true)
    expect(user.errors[:name].any? { |msg| msg == "should be Paul" }).to eq(true)
    expect(user.errors[:name].size).to eq(2)
  end

  it "should clear the errors on subsequent calls to valid?" do
    user = ValidatedUser.new(name: nil)
    expect(user.valid?).to eq(false)
    user.name = "Paul"
    expect(user.valid?).to eq(true)
    expect(user.errors[:name]).to eq([])
  end
end

describe "validation callbacks and filter halt" do
  class FilterValidationUpdateUser
    include CouchPotato::Persistence

    property :name
    before_validation :check_name
    before_validation_on_update :abort_callback

    def check_name
      errors.add(:name, "should be Paul") unless name == "Paul"
    end

    def abort_callback
      false
    end
  end

  class FilterValidationCreateUser
    include CouchPotato::Persistence

    property :name
    before_validation :check_name
    before_validation_on_save :abort_callback
    before_validation_on_create :abort_callback

    def check_name
      errors.add(:name, "should be Paul") unless name == "Paul"
    end

    def abort_callback
      false
    end
  end

  class FilterSaveUpdateUser
    include CouchPotato::Persistence

    property :name
    before_update :abort_callback

    def abort_callback
      false
    end
  end

  class FilterSaveCreateUser
    include CouchPotato::Persistence

    property :name
    before_save :abort_callback
    before_create :abort_callback

    def abort_callback
      false
    end
  end

  before(:each) do
    recreate_db
    @db = CouchPotato.database
  end

  it "should keep error messages set in custom before_validation if an update filter returns false" do
    @user = FilterValidationUpdateUser.new(name: "Paul")
    expect(@db.save_document(@user)).to eq(true)
    @user.name = "Bert"
    expect(@db.save_document(@user)).to eq(false)
  end

  it "should keep error messages set in custom before_validation if a create filter returns false" do
    @user = FilterValidationCreateUser.new(name: "Bert")
    expect(@db.save_document(@user)).to eq(false)
  end

  if ActiveModel.version.segments.first < 5
    it "should return false on saving a document when a before update filter returned false" do
      @user = FilterSaveUpdateUser.new(name: "Paul")
      expect(@db.save_document(@user)).to eq(true)
      @user.name = "Bert"
      expect(@db.save_document(@user)).to eq(false)
    end

    it "should return false on saving a document when a before save or before create filter returned false" do
      @user = FilterSaveCreateUser.new(name: "Bert")
      expect(@db.save_document(@user)).to eq(false)
    end
  else
    class FilterSaveCreateUser5 < FilterSaveCreateUser
      def abort_callback
        throw :abort
      end
    end

    class FilterSaveUpdateUser5 < FilterSaveUpdateUser
      def abort_callback
        throw :abort
      end
    end

    it "returns false on saving a document when a before update filter throws :abort" do
      @user = FilterSaveUpdateUser5.new(name: "Paul")
      expect(@db.save_document(@user)).to eq(true)
      @user.name = "Bert"
      expect(@db.save_document(@user)).to eq(false)
    end

    it "returns false on saving a document when a before save or before create filter throws :abort" do
      @user = FilterSaveCreateUser5.new(name: "Bert")
      expect(@db.save_document(@user)).to eq(false)
    end
  end
end
