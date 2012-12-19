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

    it "raises an error when passing invalid view parameters" do
      lambda {
        CouchPotato::View::BaseViewSpec.new Object, 'all', {}, {:start_key => '1'}
      }.should raise_error(ArgumentError, "invalid view parameter: start_key")
    end

    it "does not raise an error when passing valid view parameters" do
      lambda {
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
          :inclusive_end => true
        }
      }.should_not raise_error
    end

    it "removes stale when it's nil" do
      spec = CouchPotato::View::BaseViewSpec.new Object, 'all', {}, {:stale => nil}
      spec.view_parameters.should == {}
    end

    it "converts a range passed as key into startkey and endkey" do
      spec = CouchPotato::View::BaseViewSpec.new Object, 'all', {}, {:key => '1'..'2'}
      spec.view_parameters.should == {:startkey => '1', :endkey => '2'}
    end

    it "converts a plain value to a hash with a key" do
      spec = CouchPotato::View::BaseViewSpec.new Object, 'all', {}, '2'
      spec.view_parameters.should == {:key => '2'}
    end

    it "generates the design document path by snake_casing the class name but keeping double colons" do
      spec = CouchPotato::View::BaseViewSpec.new 'Foo::BarBaz', '', {}, ''
      spec.design_document.should == 'foo::bar_baz'
    end

    it "generates the design document independent of the view name by default" do
      CouchPotato::Config.split_design_documents_per_view = false
      spec = CouchPotato::View::BaseViewSpec.new 'User', 'by_login_and_email', {}, ''
      spec.design_document.should == 'user'
    end

    it "generates the design document per view if configured to" do
      CouchPotato::Config.split_design_documents_per_view = true
      spec = CouchPotato::View::BaseViewSpec.new 'User', 'by_login_and_email', {}, ''
      spec.design_document.should == 'user_view_by_login_and_email'
    end

    it "generates the design document independent of the list name by default" do
      CouchPotato::Config.split_design_documents_per_view = false
      spec = CouchPotato::View::BaseViewSpec.new stub(:lists => nil, :to_s => 'User'), '', {:list => 'test_list'}, {}
      spec.design_document.should == 'user'
    end

    it "generates the design document per view if configured to" do
      CouchPotato::Config.split_design_documents_per_view = true
      spec = CouchPotato::View::BaseViewSpec.new stub(:lists => nil, :to_s => 'User'), '', {:list => :test_list}, {}
      spec.design_document.should == 'user_list_test_list'
    end

    it "extracts the list name from the options" do
      spec = CouchPotato::View::BaseViewSpec.new stub(:lists => nil), 'all', {:list => :test_list}, {}
      spec.list_name.should == :test_list
    end

    it "extracts the list from the view parameters" do
      spec = CouchPotato::View::BaseViewSpec.new stub(:lists => nil), 'all', {}, {:list => :test_list}
      spec.list_name.should == :test_list
    end

    it "prefers the list name from the view parameters over the one from the options" do
      spec = CouchPotato::View::BaseViewSpec.new stub(:lists => nil), 'all', {:list => 'my_list'}, {:list => :test_list}
      spec.list_name.should == :test_list
    end

    it "returns the list function" do
      klass = stub 'class'
      klass.stub(:lists).with('test_list').and_return('<list_code>')
      spec = CouchPotato::View::BaseViewSpec.new klass, 'all', {:list => 'test_list'}, {}
      spec.list_function.should == '<list_code>'
    end

    it 'reads the language from the couch potato config by default' do
      CouchPotato::Config.default_language = :ruby
      spec = CouchPotato::View::BaseViewSpec.new Object, 'all', {}, {}
      spec.language.should == :ruby
    end

    it 'sets the language to the given language' do
      spec = CouchPotato::View::BaseViewSpec.new Object, 'all', {:language => :erlang}, {}
      spec.language.should == :erlang
    end

    it 'post-processes the results' do
      filter = lambda{ |results| results.map{|r| r.to_i} }
      spec = CouchPotato::View::BaseViewSpec.new Object, 'all', {:results_filter => filter}, {}

      expect(spec.process_results(['1'])).to eql([1])
    end
  end
end


