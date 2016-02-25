require 'spec_helper'

describe CouchPotato::View::BaseViewSpec, 'initialize' do
  describe "view parameters" do
    before(:each) do
      CouchPotato::Config.split_design_documents_per_view = false
      @default_language = CouchPotato::Config.default_language
    end

    after(:each) do
      CouchPotato::Config.default_language = @default_language
    end

    it 'raises an error when passing invalid view parameters' do
      expect {
        CouchPotato::View::BaseViewSpec.new Object, 'all', {}, {start_key: '1'}
      }.to raise_error(ArgumentError, "invalid view parameter: start_key")
    end

    it 'does not raise an error when passing valid view parameters' do
      expect {
        CouchPotato::View::BaseViewSpec.new Object, 'all', {}, {
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
          :inclusive_end => true,
          :list_params => {}
        }
      }.not_to raise_error
    end

    it "removes stale when it's nil" do
      spec = CouchPotato::View::BaseViewSpec.new Object, 'all', {}, {:stale => nil}
      expect(spec.view_parameters).to eq({})
    end

    it "converts a range passed as key into startkey and endkey" do
      spec = CouchPotato::View::BaseViewSpec.new Object, 'all', {}, {:key => '1'..'2'}
      expect(spec.view_parameters).to eq({:startkey => '1', :endkey => '2'})
    end

    it "converts a plain value to a hash with a key" do
      spec = CouchPotato::View::BaseViewSpec.new Object, 'all', {}, '2'
      expect(spec.view_parameters).to eq({:key => '2'})
    end

    it 'merges the list params' do
      spec = CouchPotato::View::BaseViewSpec.new Object, 'all', {}, key: '2', list_params: {:x => 'y'}
      expect(spec.view_parameters).to eq({:key => '2', :x => 'y'})
    end

    it "generates the design document path by snake_casing the class name but keeping double colons" do
      spec = CouchPotato::View::BaseViewSpec.new 'Foo::BarBaz', '', {}, ''
      expect(spec.design_document).to eq('foo::bar_baz')
    end

    it "generates the design document independent of the view name by default" do
      CouchPotato::Config.split_design_documents_per_view = false
      spec = CouchPotato::View::BaseViewSpec.new 'User', 'by_login_and_email', {}, ''
      expect(spec.design_document).to eq('user')
    end

    it "generates the design document per view if configured to" do
      CouchPotato::Config.split_design_documents_per_view = true
      spec = CouchPotato::View::BaseViewSpec.new 'User', 'by_login_and_email', {}, ''
      expect(spec.design_document).to eq('user_view_by_login_and_email')
    end

    it "generates the design document independent of the list name by default" do
      CouchPotato::Config.split_design_documents_per_view = false
      spec = CouchPotato::View::BaseViewSpec.new double(lists: nil, :to_s => 'User'), '', {list: 'test_list'}, {}
      expect(spec.design_document).to eq('user')
    end

    it "generates the design document per view if configured to" do
      CouchPotato::Config.split_design_documents_per_view = true
      spec = CouchPotato::View::BaseViewSpec.new double(lists: nil, :to_s => 'User'), '', {list: :test_list}, {}
      expect(spec.design_document).to eq('user_list_test_list')
    end

    it "extracts the list name from the options" do
      spec = CouchPotato::View::BaseViewSpec.new double(lists: nil), 'all', {list: :test_list}, {}
      expect(spec.list_name).to eq(:test_list)
    end

    it "extracts the list from the view parameters" do
      spec = CouchPotato::View::BaseViewSpec.new double(lists: nil), 'all', {}, {list: :test_list}
      expect(spec.list_name).to eq(:test_list)
    end

    it "prefers the list name from the view parameters over the one from the options" do
      spec = CouchPotato::View::BaseViewSpec.new double(lists: nil), 'all', {list: 'my_list'}, list: :test_list
      expect(spec.list_name).to eq(:test_list)
    end

    it 'returns the view name' do
      spec = CouchPotato::View::BaseViewSpec.new Object, 'by_id', {}, {}
      expect(spec.view_name).to eq('by_id')
    end

    it 'adds a digest to the view name based on the map function content when passing digest_view_name' do
      # need to use RawViewSpec here so we can pass a map function
      spec = CouchPotato::View::RawViewSpec.new Object, 'by_id',
        {digest_view_name: true, map: 'function() {}'}, {}

      expect(spec.view_name).to eq('by_id-4644e3a3ef266d4e6b513dc79bad5ab7')
    end

    it 'adds a digest to the view name if configure to' do
      begin
        CouchPotato::Config.digest_view_names = true
        # need to use RawViewSpec here so we can pass a map function
        spec = CouchPotato::View::RawViewSpec.new Object, 'by_id',
          {map: 'function() {}'}, {}

        expect(spec.view_name).to eq('by_id-4644e3a3ef266d4e6b513dc79bad5ab7')
      ensure
        CouchPotato::Config.digest_view_names = false
      end
    end

    it "returns the list function" do
      klass = double 'class'
      allow(klass).to receive(:lists).with('test_list').and_return('<list_code>')
      spec = CouchPotato::View::BaseViewSpec.new klass, 'all', {list: 'test_list'}, {}
      expect(spec.list_function).to eq('<list_code>')
    end

    it 'reads the language from the couch potato config by default' do
      CouchPotato::Config.default_language = :ruby
      spec = CouchPotato::View::BaseViewSpec.new Object, 'all', {}, {}
      expect(spec.language).to eq(:ruby)
    end

    it 'sets the language to the given language' do
      spec = CouchPotato::View::BaseViewSpec.new Object, 'all', {language: :erlang}, {}
      expect(spec.language).to eq(:erlang)
    end

    it 'post-processes the results' do
      filter = -> (results) { results.map(&:to_i) }
      spec = CouchPotato::View::BaseViewSpec.new Object, 'all', {results_filter: filter}, {}

      expect(spec.process_results(['1'])).to eql([1])
    end
  end
end
