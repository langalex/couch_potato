require 'spec_helper'

class Build
  include CouchPotato::Persistence

  property :state
  property :time
  property :type, :type => String, :default => 'Build'

  view :timeline, :key => :time
  view :count, :key => :time, :reduce => true
  view :minimal_timeline, :key => :time, :properties => [:state], :type => :properties
  view :key_array_timeline, :key => [:time, :state]
  view :custom_timeline, :map => "function(doc) { emit(doc._id, {state: 'custom_' + doc.state}); }", :type => :custom
  view :custom_timeline_returns_docs, :map => "function(doc) { emit(doc._id, null); }", :include_docs => true, :type => :custom
  view :custom_with_reduce, :map => "function(doc) {if(doc.foreign_key) {emit(doc.foreign_key, 1);} else {emit(doc._id, 1)}}", :reduce => "function(key, values) {return({\"count\": sum(values)});}", :group => true, :type => :custom
  view :custom_count_with_reduce, :map => "function(doc) {if(doc.foreign_key) {emit(doc.foreign_key, 1);} else {emit(doc._id, 1)}}", :reduce => "function(key, values) {return(sum(values));}", :group => true, :type => :custom
  view :raw, :type => :raw, :map => "function(doc) {emit(doc._id, doc.state)}"
  view :filtered_raw, :type => :raw, :map => "function(doc) {emit(doc._id, doc.state)}", :results_filter => lambda{|res| res['rows'].map{|row| row['value']}}
  view :with_view_options, :group => true, :key => :time
  view :all, :map => "function(doc) { if (doc && doc.type == 'Build') emit(doc._id, 1); }", :include_docs => true, :type => :custom
end

class CustomBuild < Build
  property :server
end

class ErlangBuild
  include CouchPotato::Persistence
  property :name
  property :code

  view :by_name, :key => :name, :language => :erlang
  view :by_name_and_code, :key => [:name, :code], :language => :erlang
end

describe 'views' do
  before(:each) do
    recreate_db
    @db = CouchPotato.database
  end

  context 'in erlang' do
    it 'builds views with single keys' do
      build = ErlangBuild.new(:name => 'erlang')
      @db.save_document build

      results = @db.view(ErlangBuild.by_name('erlang'))
      expect(results).to eq([build])
    end

    it 'does not crash couchdb when a document does not have the key' do
      build = {'ruby_class' => 'ErlangBuild'}
      @db.couchrest_database.save_doc build

      results = @db.view(ErlangBuild.by_name(:key => nil))
      expect(results.size).to eq(1)
    end

    it 'builds views with composite keys' do
      build = ErlangBuild.new(:name => 'erlang', :code => '123')
      @db.save_document build

      results = @db.view(ErlangBuild.by_name_and_code(['erlang', '123']))
      expect(results).to eq([build])
    end

    it 'can reduce over erlang views' do
      build = ErlangBuild.new(:name => 'erlang')
      @db.save_document build

      results = @db.view(ErlangBuild.by_name(:reduce => true))
      expect(results).to eq(1)
    end
  end

  it "should return instances of the class" do
    @db.save_document Build.new(:state => 'success', :time => '2008-01-01')
    results = @db.view(Build.timeline)
    expect(results.map(&:class)).to eq([Build])
  end

  it "should return the ids if there document was not included" do
    build = Build.new(:state => 'success', :time => '2008-01-01')
    @db.save_document build
    results = @db.view(Build.timeline(:include_docs => false))
    expect(results).to eq([build.id])
  end

  it "should pass the view options to the view query" do
    query = double 'query'
    allow(CouchPotato::View::ViewQuery).to receive(:new).and_return(query)
    expect(query).to receive(:query_view!).with(hash_including(:key => 1)).and_return('rows' => [])
    @db.view Build.timeline(:key => 1)
  end

  it "should not return documents that don't have a matching JSON.create_id" do
    CouchPotato.couchrest_database.save_doc({:time => 'x'})
    expect(@db.view(Build.timeline)).to eq([])
  end

  it "should count documents" do
    @db.save_document! Build.new(:state => 'success', :time => '2008-01-01')
    expect(@db.view(Build.count(:reduce => true))).to eq(1)
  end

  it "should count zero documents" do
    expect(@db.view(Build.count(:reduce => true))).to eq(0)
  end

  describe "with multiple keys" do
    it "should return the documents with matching keys" do
      build = Build.new(:state => 'success', :time => '2008-01-01')
      @db.save! build
      expect(@db.view(Build.timeline(:keys => ['2008-01-01']))).to eq([build])
    end

    it "should not return documents with non-matching keys" do
      build = Build.new(:state => 'success', :time => '2008-01-01')
      @db.save! build
      expect(@db.view(Build.timeline(:keys => ['2008-01-02']))).to be_empty
    end
  end

  describe "properties defined" do
    it "assigns the configured properties" do
      CouchPotato.couchrest_database.save_doc(:state => 'success', :time => '2008-01-01', JSON.create_id.to_sym => 'Build')
      expect(@db.view(Build.minimal_timeline).first.state).to eql('success')
    end

    it "does not assign the properties not configured" do
      CouchPotato.couchrest_database.save_doc(:state => 'success', :time => '2008-01-01', JSON.create_id.to_sym => 'Build')
      expect(@db.view(Build.minimal_timeline).first.time).to be_nil
    end

    it "assigns the id even if it is not configured" do
      id = CouchPotato.couchrest_database.save_doc(:state => 'success', :time => '2008-01-01', JSON.create_id.to_sym => 'Build')['id']
      expect(@db.view(Build.minimal_timeline).first._id).to eql(id)
    end
  end

  describe "no properties defined" do
    it "should assign all properties to the objects by default" do
      id = CouchPotato.couchrest_database.save_doc({:state => 'success', :time => '2008-01-01', JSON.create_id.to_sym => 'Build'})['id']
      result = @db.view(Build.timeline).first
      expect(result.state).to eq('success')
      expect(result.time).to eq('2008-01-01')
      expect(result._id).to eq(id)
    end
  end

  describe "map function given" do
    it "should still return instances of the class" do
      CouchPotato.couchrest_database.save_doc({:state => 'success', :time => '2008-01-01'})
      expect(@db.view(Build.custom_timeline).map(&:class)).to eq([Build])
    end

    it "should assign the properties from the value" do
      CouchPotato.couchrest_database.save_doc({:state => 'success', :time => '2008-01-01'})
      expect(@db.view(Build.custom_timeline).map(&:state)).to eq(['custom_success'])
    end

    it "should assign the id" do
      doc = CouchPotato.couchrest_database.save_doc({:state => 'success', :time => '2008-01-01'})
      expect(@db.view(Build.custom_timeline).map(&:_id)).to eq([doc['id']])
    end

    it "should leave the other properties blank" do
      CouchPotato.couchrest_database.save_doc({:state => 'success', :time => '2008-01-01'})
      expect(@db.view(Build.custom_timeline).map(&:time)).to eq([nil])
    end

    describe "that returns null documents" do
      it "should return instances of the class" do
        CouchPotato.couchrest_database.save_doc({:state => 'success', :time => '2008-01-01'})
        expect(@db.view(Build.custom_timeline_returns_docs).map(&:class)).to eq([Build])
      end

      it "should assign the properties from the value" do
        CouchPotato.couchrest_database.save_doc({:state => 'success', :time => '2008-01-01'})
        expect(@db.view(Build.custom_timeline_returns_docs).map(&:state)).to eq(['success'])
      end

      it "should still return instance of class if document included JSON.create_id" do
        CouchPotato.couchrest_database.save_doc({:state => 'success', :time => '2008-01-01', JSON.create_id.to_sym => "Build"})
        view_data = @db.view(Build.custom_timeline_returns_docs)
        expect(view_data.map(&:class)).to eq([Build])
        expect(view_data.map(&:state)).to eq(['success'])
      end
    end

    describe "additional reduce function given" do
      it "should still assign the id" do
        doc = CouchPotato.couchrest_database.save_doc({})
        CouchPotato.couchrest_database.save_doc({:foreign_key => doc['id']})
        expect(@db.view(Build.custom_with_reduce).map(&:_id)).to eq([doc['id']])
      end

      describe "when the additional reduce function is a typical count" do
        it "should parse the reduce count" do
          doc = CouchPotato.couchrest_database.save_doc({})
          CouchPotato.couchrest_database.save_doc({:foreign_key => doc['id']})
          expect(@db.view(Build.custom_count_with_reduce(:reduce => true))).to eq(2)
        end
      end
    end
  end

  describe "with array as key" do
    it "should create a map function with the composite key" do
      expect(CouchPotato::View::ViewQuery).to receive(:new) do |db, design_name, view, list|
        expect(view['key_array_timeline'][:map]).to match(/emit\(\[doc\['time'\], doc\['state'\]\]/)

        double('view query', :query_view! => {'rows' => []})
      end
      @db.view Build.key_array_timeline
    end
  end

  describe "raw view" do
    it "should return the raw data" do
      @db.save_document Build.new(:state => 'success', :time => '2008-01-01')
      expect(@db.view(Build.raw)['rows'][0]['value']).to eq('success')
    end

    it "should return filtred raw data" do
      @db.save_document Build.new(:state => 'success', :time => '2008-01-01')
      expect(@db.view(Build.filtered_raw)).to eq(['success'])
    end

    it "should pass view options declared in the view declaration to the query" do
     view_query = double 'view_query'
     allow(CouchPotato::View::ViewQuery).to receive(:new).and_return(view_query)
     expect(view_query).to receive(:query_view!).with(hash_including(:group => true)).and_return({'rows' => []})
     @db.view(Build.with_view_options)
    end
  end

  describe "inherited views" do
    it "should support parent views for objects of the subclass" do
      @db.save_document CustomBuild.new(:state => 'success', :time => '2008-01-01')
      expect(@db.view(CustomBuild.timeline).size).to eq(1)
      expect(@db.view(CustomBuild.timeline).first).to be_kind_of(CustomBuild)
    end

    it "should return instances of subclasses as well if a special view exists" do
      @db.save_document Build.new(:state => 'success', :time => '2008-01-01')
      @db.save_document CustomBuild.new(:state => 'success', :time => '2008-01-01', :server => 'Jenkins')
      results = @db.view(Build.all)
      expect(results.map(&:class)).to eq([CustomBuild, Build])
    end
  end

  describe "list functions" do
    class Coworker
      include CouchPotato::Persistence

      property :name

      view :all_with_list, :key => :name, :list => :append_doe
      view :all, :key => :name

      list :append_doe, <<-JS
        function(head, req) {
          var row;
          send('{"rows": [');
          while(row = getRow()) {
            row.doc.name = row.doc.name + ' doe';
            send(JSON.stringify(row));
          };
          send(']}');
        }
      JS
    end

    it "should use the list function declared at class level" do
      @db.save! Coworker.new(:name => 'joe')
      expect(@db.view(Coworker.all_with_list).first.name).to eq('joe doe')
    end

    it "should use the list function passed at runtime" do
      @db.save! Coworker.new(:name => 'joe')
      expect(@db.view(Coworker.all(:list => :append_doe)).first.name).to eq('joe doe')
    end
  end

  describe 'with stale views' do
    it 'does not return deleted documents' do
      build = Build.new
      @db.save_document! build
      @db.view(Build.timeline)
      @db.destroy build

      expect(@db.view(Build.timeline(:stale => 'ok'))).to be_empty
    end
  end
end
