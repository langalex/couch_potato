require 'spec_helper'

describe CouchPotato::View::BaseViewSpec, 'initialize' do
  describe "view parameters" do
    it "should raise an error when passing invalid view parameters" do
      lambda {
        CouchPotato::View::BaseViewSpec.new Object, 'all', {}, {:start_key => '1'}
      }.should raise_error(ArgumentError, "invalid view parameter: start_key")
    end

    it "should not raise an error when passing valid view parameters" do
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

    it "should convert a range passed as key into startkey and endkey" do
      spec = CouchPotato::View::BaseViewSpec.new Object, 'all', {}, {:key => '1'..'2'}
      spec.view_parameters.should == {:startkey => '1', :endkey => '2'}
    end

    it "should convert a plain value to a hash with a key" do
      spec = CouchPotato::View::BaseViewSpec.new Object, 'all', {}, '2'
      spec.view_parameters.should == {:key => '2'}
    end

    it "should generate the design document path by snake_casing the class name but keeping double colons" do
      spec = CouchPotato::View::BaseViewSpec.new 'Foo::BarBaz', '', {}, ''
      spec.design_document.should == 'foo::bar_baz'
    end
    
    it "should extract the list name from the options" do
      spec = CouchPotato::View::BaseViewSpec.new stub(:lists => nil), 'all', {:list => 'test_list'}, {}
      spec.list_name.should == 'test_list'
    end
    
    it "should extract the list from the view parameters" do
      spec = CouchPotato::View::BaseViewSpec.new stub(:lists => nil), 'all', {}, {:list => 'test_list'}
      spec.list_name.should == 'test_list'
    end
    
    it "should prefer the list name from the view parameters over the one from the options" do
      spec = CouchPotato::View::BaseViewSpec.new stub(:lists => nil), 'all', {:list => 'my_list'}, {:list => 'test_list'}
      spec.list_name.should == 'test_list'
    end
    
    it "should return the list function" do
      klass = stub 'class'
      klass.stub(:lists).with('test_list').and_return('<list_code>')
      spec = CouchPotato::View::BaseViewSpec.new klass, 'all', {:list => 'test_list'}, {}
      spec.list_function.should == '<list_code>'
    end

  end

end


