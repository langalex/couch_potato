require 'spec_helper'

class Test
  include CouchPotato::Persistence

  property :test, :default => 'Test value'
  property :complex, :default => [1, 2, 3]
  property :false_value, :default => false
  property :proc, :default => Proc.new { 1 + 2 }
  property :proc_arity_one, :default => Proc.new {|test| test.test * 2 }
end

describe 'default properties' do
  before(:all) do
    recreate_db
  end

  it "uses the default value if nothing is supplied" do
    t = Test.new

    t.test.should == 'Test value'
  end

  it "persists the default value if nothing is supplied" do
    t = Test.new
    CouchPotato.database.save_document! t

    t = CouchPotato.database.load_document t.id
    t.test.should == 'Test value'
  end

  it "does not have the same default for two instances of the object" do
    t = Test.new
    t2 = Test.new
    t.complex.object_id.should_not == t2.complex.object_id
  end

  it "does not return the default value when the actual value is empty" do
    t = Test.new(:complex => []).complex.should == []
  end

  it "uses the default value also if the default is false" do
    t = Test.new
    t.false_value.should == false
  end

  it "uses the return value of a Proc given as the default" do
    t = Test.new
    t.proc.should == 3
  end

  it 'passes the model to a block with arity 1' do
    t = Test.new

    expect(t.proc_arity_one).to eql('Test valueTest value')
  end
end
