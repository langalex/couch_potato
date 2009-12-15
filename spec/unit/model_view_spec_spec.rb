require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe CouchPotato::View::ModelViewSpec, 'map_function' do
  it "should include conditions" do
    spec = CouchPotato::View::ModelViewSpec.new Object, 'all', {:conditions => 'doc.closed = true'}, {}
    spec.map_function.should include('if(doc.ruby_class && doc.ruby_class == \'Object\' && (doc.closed = true))')
  end
  
  it "should not include conditions when they are nil" do
    spec = CouchPotato::View::ModelViewSpec.new Object, 'all', {}, {}
    spec.map_function.should include('if(doc.ruby_class && doc.ruby_class == \'Object\')')
  end
end