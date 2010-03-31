require 'spec_helper'

describe String, 'camelize' do
  it "should camelize a string" do
    'my_string'.camelize.should == 'MyString'
  end
end

describe String, 'snake_case' do
  it "should snake_case a string" do
    'MyString'.snake_case.should == 'my_string'
  end

  it "should snake_case a string using a custom separator" do
    'My::String'.snake_case('::').should == 'my::string'
  end
end