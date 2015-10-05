require 'spec_helper'

describe String, 'camelize' do
  it "should camelize a string" do
    expect('my_string'.camelize).to eq('MyString')
  end
end
