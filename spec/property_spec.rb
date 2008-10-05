require File.dirname(__FILE__) + '/spec_helper'

describe 'properties' do
  it "should return the property names" do
    Comment.property_names.should == [:title, :commenter]
  end
  
  it "should persist a string" do
    c = Comment.new :title => 'my title'
    c.save!
    c = Comment.find c.id
    c.title.should == 'my title'
  end
  
  it "should persist a number" do
    c = Comment.new :title => 3
    c.save!
    c = Comment.find c.id
    c.title.should == 3
  end
  
  it "should persist a hash" do
    c = Comment.new :title => {'key' => 'value'}
    c.save!
    c = Comment.find c.id
    c.title.should == {'key' => 'value'}
  end
end