require File.dirname(__FILE__) + '/../spec_helper'

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
    
  end
  
end


