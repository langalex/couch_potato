require 'spec_helper'

describe CouchPotato::View::ModelViewSpec, '#process_results' do
  it 'returns the documents' do
    spec = CouchPotato::View::ModelViewSpec.new(Object, 'all', {}, {})
    processed_results = spec.process_results('rows' => [{'doc' => 'doc-1'}])

    expect(processed_results).to eql(['doc-1'])
  end

  it 'returns ids where there are no documents' do
    spec = CouchPotato::View::ModelViewSpec.new(Object, 'all', {}, {:include_docs => false})
    processed_results = spec.process_results('rows' => [{'id' => 'doc-1'}])

    expect(processed_results).to eql(['doc-1'])
  end

  it 'filters out rows without documents when include_docs=true (i.e. doc has been deleted)' do
    spec = CouchPotato::View::ModelViewSpec.new(Object, 'all', {}, {:include_docs => true})
    processed_results = spec.process_results('rows' => [{'id' => 'doc-1'}])

    expect(processed_results).to be_empty
  end
end

describe CouchPotato::View::ModelViewSpec, '#map_function' do
  it "should include conditions" do
    spec = CouchPotato::View::ModelViewSpec.new Object, 'all', {:conditions => 'doc.closed = true'}, {}
    expect(spec.map_function).to include('if(doc.ruby_class && doc.ruby_class == \'Object\' && (doc.closed = true))')
  end

  it 'generates an erlang map function with a single key if the language is erlang' do
    spec = CouchPotato::View::ModelViewSpec.new Object, 'all', {:key => :name, :language => :erlang}, {}
    expect(spec.map_function).to eql_ignoring_indentation(<<-ERL
      fun({Doc}) ->
        case proplists:get_value(<<"ruby_class">>, Doc) of
        <<"Object">> ->
            Key = proplists:get_value(<<"name">>, Doc, null),
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
    expect(spec.map_function).to eql_ignoring_indentation(<<-ERL
      fun({Doc}) ->
        case proplists:get_value(<<"ruby_class">>, Doc) of
        <<"Object">> ->
            Key_0 = proplists:get_value(<<"code">>, Doc, null),
            Key_1 = proplists:get_value(<<"name">>, Doc, null),
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
    expect {
      spec.map_function
    }.to raise_error(NotImplementedError)
  end

  it 'does not support a custom emit value in erlang' do
    spec = CouchPotato::View::ModelViewSpec.new Object, 'all', {:language => :erlang, :emit_value => :count}, {}
    expect {
      spec.map_function
    }.to raise_error(NotImplementedError)
  end

  it "should not include conditions when they are nil" do
    spec = CouchPotato::View::ModelViewSpec.new Object, 'all', {}, {}
    expect(spec.map_function).to include('if(doc.ruby_class && doc.ruby_class == \'Object\')')
  end

  it "should have a custom emit value when specified as symbol" do
    spec = CouchPotato::View::ModelViewSpec.new Object, 'all', {:emit_value => :count}, {}
    expect(spec.map_function).to include(%{emit(doc[''], doc['count'])})
  end

  it "should have a custom emit value when specified as string" do
    spec = CouchPotato::View::ModelViewSpec.new Object, 'all', {:emit_value => "doc['a'] + doc['b']"}, {}
    expect(spec.map_function).to include("emit(doc[''], doc['a'] + doc['b'])")
  end

  it "should have a custom emit value when specified as integer" do
    spec = CouchPotato::View::ModelViewSpec.new Object, 'all', {:emit_value => 7}, {}
    expect(spec.map_function).to include("emit(doc[''], 7)")
  end

  it "should have a custom emit value when specified as float" do
    spec = CouchPotato::View::ModelViewSpec.new Object, 'all', {:emit_value => 7.2}, {}
    expect(spec.map_function).to include("emit(doc[''], 7.2")
  end

  it "should have a emit value of 1 when nothing is specified" do
    spec = CouchPotato::View::ModelViewSpec.new Object, 'all', {}, {}
    expect(spec.map_function).to include("emit(doc[''], 1")
  end

  it "should raise exception when emit value cannot be handled" do
    spec = CouchPotato::View::ModelViewSpec.new Object, 'all', {:emit_value => []}, {}
    expect { spec.map_function }.to raise_error
  end
end
