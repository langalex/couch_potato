require 'spec_helper'

describe 'CouchPotato Validation' do
  
  describe "access to errors object" do
    it "should description" do
      model_class = Class.new
      model_class.send(:include, CouchPotato::Persistence)
      model_class.new.errors.should respond_to(:errors)
    end
  end

end
