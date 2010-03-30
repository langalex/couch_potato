require File.dirname(__FILE__) + '/spec_helper'
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


describe CouchPotato::Database, 'rails specific behavior' do
  
  it "should load models whose constants are currently uninitialized (like with rails in development mode)" do
    recreate_db
    CouchPotato.couchrest_database.save_doc(JSON.create_id => 'Autoloader::Uninitialized', '_id' => '1')
    CouchPotato.database.load('1').class.name.should == 'Autoloader::Uninitialized'
  end
  
  it "should load nested models" do
    recreate_db
    CouchPotato.couchrest_database.save_doc(JSON.create_id => 'Autoloader::Nested::Nested2', '_id' => '1')
    CouchPotato.database.load('1').class.name.should == 'Autoloader::Nested::Nested2'
  end
  
end

