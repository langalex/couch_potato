require 'spec_helper'

describe String, 'camelize' do
  it "should camelize a string" do
    'my_string'.camelize.should == 'MyString'
  end
end
