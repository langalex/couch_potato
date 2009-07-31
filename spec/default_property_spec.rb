require File.dirname(__FILE__) + '/spec_helper'

class Test
  include CouchPotato::Persistence

  property :test, :default => 'Test value'
  property :complex, :default => []
end

describe 'default properties' do
  before(:all) do
    recreate_db
  end

  it "should use the default value if nothing is supplied" do
    t = Test.new

    t.test.should == 'Test value'
  end

  it "should persist the default value if nothing is supplied" do
    t = Test.new
    CouchPotato.database.save_document! t

    t = CouchPotato.database.load_document t.id
    t.test.should == 'Test value'
  end

  it "should not have the same default for two instances of the object" do
    t = Test.new
    t2 = Test.new
    t.complex.object_id.should_not == t2.complex.object_id
  end
end
