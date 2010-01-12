require File.dirname(__FILE__) + '/../spec_helper'

describe CouchPotato::View::ModelViewSpec, 'map_function' do
  it "should include conditions" do
    spec = CouchPotato::View::ModelViewSpec.new Object, 'all', {:conditions => 'doc.closed = true'}, {}
    spec.map_function.should include('if(doc.ruby_class && doc.ruby_class == \'Object\' && (doc.closed = true))')
  end
  
  it "should not include conditions when they are nil" do
    spec = CouchPotato::View::ModelViewSpec.new Object, 'all', {}, {}
    spec.map_function.should include('if(doc.ruby_class && doc.ruby_class == \'Object\')')
  end
  
  it "should raise an error when passing invalid view parameters" do
    lambda {
      CouchPotato::View::ModelViewSpec.new Object, 'all', {}, {:start_key => '1'}
    }.should raise_error(ArgumentError, "invalid view parameter: start_key")
  end
  
  it "should not raise an error when passing valid view parameters" do
    lambda {
      CouchPotato::View::ModelViewSpec.new Object, 'all', {}, {
        :key => 'keyvalue',
        :startkey => 'keyvalue',
        :startkey_docid => 'docid',
        :endkey => 'keyvalue',
        :endkey_docid => 'docid',
        :limit => 3,
        :stale => 'ok',
        :descending => true,
        :skip => 1,
        :group => true,
        :group_level => 1,
        :reduce => false,
        :include_docs => true,
        :inclusive_end => true
      }
    }.should_not raise_error
  end
end