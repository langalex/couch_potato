require 'spec_helper'
require File.dirname(__FILE__) + '/../rails/reload_classes'

module LoadConst
  def const_missing(name)
    name = "#{self.name}::#{name}"
    eval("#{name} = Class.new; #{name}.send(:include, CouchPotato::Persistence); #{name}.extend(LoadConst)")
  end
end

class Autoloader
  extend LoadConst
end

class WithUnloadedEmbedded
  include CouchPotato::Persistence
  extend LoadConst
  
  property :embedded
  
  view :all, :type => :custom, :map => 'function(doc) {emit(doc._id, null)}', :include_docs => true
end


describe CouchPotato::Database, 'rails specific behavior' do
  
  before(:each) do
    recreate_db
  end
  
  context 'load a document' do
    it "should load models whose constants are currently uninitialized (like with rails in development mode)" do
      CouchPotato.couchrest_database.save_doc(JSON.create_id => 'Autoloader::Uninitialized', '_id' => '1')
      CouchPotato.database.load('1').class.name.should == 'Autoloader::Uninitialized'
    end
  
    it "should load nested models" do
      CouchPotato.couchrest_database.save_doc(JSON.create_id => 'Autoloader::Nested::Nested2', '_id' => '1')
      CouchPotato.database.load('1').class.name.should == 'Autoloader::Nested::Nested2'
    end
  end  
  
  context 'load documents using a view' do
    it "should load models from a view whose constants are currently uninitialized" do
      doc = {JSON.create_id => 'WithUnloadedEmbedded', '_id' => '1', 'embedded' => {JSON.create_id => 'WithUnloadedEmbedded::Uninitialized'}}
      CouchPotato.couchrest_database.save_doc(doc)
      CouchPotato.database.view(WithUnloadedEmbedded.all).first.embedded.class.name.should == 'WithUnloadedEmbedded::Uninitialized'
    end
  end
end

