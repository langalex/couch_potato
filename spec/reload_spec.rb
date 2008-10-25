require File.dirname(__FILE__) + '/spec_helper'

describe 'reload' do
  class Table
    include CouchPotato::Persistence
    property :rows
    has_many :cols, :stored => :inline
    has_many :ext_cols, :stored => :separately
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
  
  it "should reload simple properties" do
    table = Table.create! :rows => 3
    table.rows = 4
    table.reload
    table.rows.should == 3
  end
  
  it "should reload inline has_many associations" do
    table = Table.new
    table.cols.build :name => 'col1'
    table.save!
    table.cols.build :name => 'col2'
    table.reload
    table.cols.size.should == 1
  end
  
  it "should reload external has_many associations" do
    table = Table.new
    table.ext_cols.build :name => 'col1'
    table.save!
    table.ext_cols.build :name => 'col2'
    table.reload
    table.ext_cols.size.should == 1
  end
end