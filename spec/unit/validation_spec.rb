require 'spec_helper'

describe 'CouchPotato Validation' do
  
  describe "access to errors object" do
    it "should description" do
      model_class = Class.new
      model_class.send(:include, CouchPotato::Persistence)
      expect(model_class.new.errors).to respond_to(:errors)
    end
  end

end
