require 'spec_helper'

describe 'CouchPotato::Config.validation_framework' do
  before(:each) do
    @original_validation_framework = CouchPotato::Config.validation_framework
  end
  after(:each) do
    CouchPotato::Config.validation_framework = @original_validation_framework
  end
  
  describe "access to errors object" do
    it "should description" do
      model_class = Class.new
      model_class.send(:include, CouchPotato::Persistence)
      model_class.new.errors.should respond_to(:errors)
    end
  end

  begin
    require 'active_model'

    describe 'with :active_model' do
      before(:each) do
        CouchPotato::Config.validation_framework = :active_model
      end

      it "should include ActiveModel::Validations upon inclusion of CouchPotato::Persistence" do
        model_class = Class.new
        ActiveModel::Validations.should_receive(:included).with(model_class)
        model_class.send(:include, CouchPotato::Persistence)
      end
    end

  rescue LoadError
    STDERR.puts "WARNING: active_model gem not installed. Not running ActiveModel validation specs."
  end

  begin
    require 'validatable'

    describe 'with :validatable' do
      before(:each) do
        CouchPotato::Config.validation_framework = :validatable
      end

      it "should include ActiveModel::Validations upon inclusion of CouchPotato::Persistence" do
        model_class = Class.new
        Validatable.should_receive(:included).with(model_class)
        model_class.send(:include, CouchPotato::Persistence)
      end
    end

  rescue LoadError
    STDERR.puts "WARNING: validatable gem not installed. Not running Validatable validation specs."
  end

  describe 'with an unknown framework' do
    before(:each) do
      CouchPotato::Config.validation_framework = :unknown_validation_framework
    end

    it "should raise an error" do
      model_class = Class.new
      lambda { model_class.send(:include, CouchPotato::Persistence) }.should raise_error
    end
  end
end
