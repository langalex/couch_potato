require File.dirname(__FILE__) + '/../spec_helper'

begin
  require 'active_model'
  
  describe 'With CouchPotato::Config.validation_framework = :active_model' do

    before(:all) do
      @original_validation_framework = CouchPotato::Config.validation_framework
      CouchPotato::Config.validation_framework = :active_model
    end
    after(:all) do
      CouchPotato::Config.validation_framework = @original_validation_framework
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

describe 'With CouchPotato::Config.validation_framework = :validatable' do

  before(:all) do
    @original_validation_framework = CouchPotato::Config.validation_framework
    CouchPotato::Config.validation_framework = :validatable
  end
  after(:all) do
    CouchPotato::Config.validation_framework = @original_validation_framework
  end

  it "should include ActiveModel::Validations upon inclusion of CouchPotato::Persistence" do
    model_class = Class.new
    Validatable.should_receive(:included).with(model_class)
    model_class.send(:include, CouchPotato::Persistence)
  end

end
