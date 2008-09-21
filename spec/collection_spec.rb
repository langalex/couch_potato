require File.dirname(__FILE__) + '/spec_helper'

describe CouchPotatoe::Persistence::Collection do
  it "should convert to and from json" do
    collection = CouchPotatoe::Persistence::Collection.new Comment
    collection << Comment.new(:title => 'comment')
    JSON.parse(collection.to_json).should == collection
  end

  it "should build elements with the item class" do
    collection = CouchPotatoe::Persistence::Collection.new Comment
    collection.build :title => 'mytitle'
    collection[0].class.should == Comment
  end
  
  it "should build elements with the given attributes" do
    collection = CouchPotatoe::Persistence::Collection.new Comment
    collection.build :title => 'mytitle'
    collection[0].title.should == 'mytitle'
  end
end
