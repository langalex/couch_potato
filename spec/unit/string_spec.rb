require File.dirname(__FILE__) + '/../spec_helper'

describe String, 'camelize' do
  it "should camelize a string" do
    'my_string'.camelize.should == 'MyString'
  end
end

describe String, 'underscore' do
  it "should underscore a string" do
    'MyString'.underscore.should == 'my_string'
  end
end