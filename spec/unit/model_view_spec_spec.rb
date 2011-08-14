require 'spec_helper'

describe CouchPotato::View::ModelViewSpec, 'map_function' do
  it "should include conditions" do
    spec = CouchPotato::View::ModelViewSpec.new Object, 'all', {:conditions => 'doc.closed = true'}, {}
    spec.map_function.should include('if(doc.ruby_class && doc.ruby_class == \'Object\' && (doc.closed = true))')
  end
  
  it "should not include conditions when they are nil" do
    spec = CouchPotato::View::ModelViewSpec.new Object, 'all', {}, {}
    spec.map_function.should include('if(doc.ruby_class && doc.ruby_class == \'Object\')')
  end

  it "should have a custom emit value when specified as symbol" do
    spec = CouchPotato::View::ModelViewSpec.new Object, 'all', {:emit_value => :count}, {}
    spec.map_function.should include(%{emit(doc[''], doc['count'])})
  end

  it "should have a custom emit value when specified as symbol" do
    spec = CouchPotato::View::ModelViewSpec.new Object, 'all', {:emit_value => "doc['a'] + doc['b']"}, {}
    spec.map_function.should include("emit(doc[''], doc['a'] + doc['b'])")
  end

  it "should have a custom emit value when specified as integer" do
    spec = CouchPotato::View::ModelViewSpec.new Object, 'all', {:emit_value => 7}, {}
    spec.map_function.should include("emit(doc[''], 7)")
  end

  it "should have a custom emit value when specified as float" do
    spec = CouchPotato::View::ModelViewSpec.new Object, 'all', {:emit_value => 7.2}, {}
    spec.map_function.should include("emit(doc[''], 7.2")
  end

  it "should have a emit value of 1 when nothing is specified" do
    spec = CouchPotato::View::ModelViewSpec.new Object, 'all', {}, {}
    spec.map_function.should include("emit(doc[''], 1")
  end

  it "should have a emit value of 1 when something else is specified" do
    spec = CouchPotato::View::ModelViewSpec.new Object, 'all', {:emit_value => []}, {}
    spec.map_function.should include("emit(doc[''], 1")
  end
end
