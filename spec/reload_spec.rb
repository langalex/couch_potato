require File.dirname(__FILE__) + '/spec_helper'

describe 'reload' do
  class Table
    include CouchPotato::Persistence
    property :rows
  end
  
  class ExtCol
    include CouchPotato::Persistence
    belongs_to :table
    property :name
  end
  
  class Col
    include CouchPotato::Persistence
    property :name
  end
  
  before(:all) do
    recreate_db
  end
  
  it "should reload simple properties" do
    table = Table.create! :rows => 3
    table.rows = 4
    table.reload
    table.rows.should == 3
  end
  

end