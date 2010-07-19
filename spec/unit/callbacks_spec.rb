require 'spec_helper'

describe 'callbacks' do
  class Tree
    include CouchPotato::Persistence

    before_validation :grow_leaf, 'grow_branch', lambda {|tree| tree.root_count ||= 0; tree.root_count += 1 }

    property :leaf_count
    property :root_count
    property :branch_count
    property :watered
    

    def grow_leaf
      self.leaf_count ||= 0
      self.leaf_count += 1
    end
    
    def grow_branch
      self.branch_count ||= 0
      self.branch_count += 1
    end
  end
  
  class AppleTree < Tree
    attr_accessor :watered
    
    before_validation :water
    
    def water
      self.watered = true
    end
    
    def watered?
      watered
    end
  end

  it "should call a method from a symbol when validated" do
    tree = Tree.new(:leaf_count => 1, :root_count => 1)
    tree.valid?
    tree.leaf_count.should == 2
  end
  
  it "should call a method from a string when validated" do
    tree = Tree.new(:branch_count => 0)
    tree.valid?
    tree.branch_count.should == 1
  end

  it "should call a lambda when validated" do
    tree = Tree.new(:leaf_count => 1, :root_count => 1)
    tree.valid?
    tree.root_count.should == 2
  end
  
  context 'inheritance' do
    it "should call the callbacks of the super class" do
      tree = AppleTree.new :leaf_count => 1
      tree.valid?
      tree.leaf_count.should == 2
    end
    
    it "should call the callbacks of the child class" do
      tree = AppleTree.new :leaf_count => 1
      tree.valid?
      tree.should be_watered
    end
  end
  
end