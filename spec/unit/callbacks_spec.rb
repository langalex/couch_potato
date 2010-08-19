require 'spec_helper'

describe 'callbacks' do
  class Tree
    include CouchPotato::Persistence

    before_validation :grow_leaf

    property :leaf_count
    property :watered

    def grow_leaf
      self.leaf_count ||= 0
      self.leaf_count += 1
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
