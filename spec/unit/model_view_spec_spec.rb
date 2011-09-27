require 'spec_helper'

describe CouchPotato::View::ModelViewSpec, 'map_function' do
  it "should include conditions" do
    spec = CouchPotato::View::ModelViewSpec.new Object, 'all', {:conditions => 'doc.closed = true'}, {}
    spec.map_function.should include('if(doc.ruby_class && doc.ruby_class == \'Object\' && (doc.closed = true))')
  end

  it 'generates an erlang map function with a single key if the language is erlang' do
    spec = CouchPotato::View::ModelViewSpec.new Object, 'all', {:key => :name, :language => :erlang}, {}
    spec.map_function.should eql_ignoring_indentation(<<-ERL
      fun({Doc}) ->
        case {proplists:get_value(<<"ruby_class">>, Doc), proplists:get_value(<<"name">>, Doc)} of
        {<<"Object">>, Key} ->
            Emit(Key, 1);
        _ ->
            ok
        end
      end.
      ERL
    )
  end

  it 'generates an erlang map function with a composite key if the language is erlang' do
    spec = CouchPotato::View::ModelViewSpec.new Object, 'all', {:key => [:code, :name], :language => :erlang}, {}
    spec.map_function.should eql_ignoring_indentation(<<-ERL
      fun({Doc}) ->
        case {proplists:get_value(<<"ruby_class">>, Doc), proplists:get_value(<<"code">>, Doc), proplists:get_value(<<"name">>, Doc)} of
        {<<"Object">>, Key_0, Key_1} ->
            Emit([Key_0, Key_1], 1);
        _ ->
            ok
        end
      end.
      ERL
    )
  end

  it 'does not support conditions in erlang' do
    spec = CouchPotato::View::ModelViewSpec.new Object, 'all', {:language => :erlang, :conditions => 'abc'}, {}
    lambda {
      spec.map_function
    }.should raise_error(NotImplementedError)
  end

  it 'does not support a custom emit value in erlang' do
    spec = CouchPotato::View::ModelViewSpec.new Object, 'all', {:language => :erlang, :emit_value => :count}, {}
    lambda {
      spec.map_function
    }.should raise_error(NotImplementedError)
  end

  it "should not include conditions when they are nil" do
    spec = CouchPotato::View::ModelViewSpec.new Object, 'all', {}, {}
    spec.map_function.should include('if(doc.ruby_class && doc.ruby_class == \'Object\')')
  end

  it "should have a custom emit value when specified as symbol" do
    spec = CouchPotato::View::ModelViewSpec.new Object, 'all', {:emit_value => :count}, {}
    spec.map_function.should include(%{emit(doc[''], doc['count'])})
  end

  it "should have a custom emit value when specified as string" do
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

  it "should raise exception when emit value cannot be handled" do
    spec = CouchPotato::View::ModelViewSpec.new Object, 'all', {:emit_value => []}, {}
    lambda { spec.map_function }.should raise_error
  end
end
