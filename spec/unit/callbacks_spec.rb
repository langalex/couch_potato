require File.dirname(__FILE__) + '/../spec_helper'

describe 'before_validation callback' do
  before(:each) do
    @original_validation_framework = CouchPotato::Config.validation_framework
  end
  after(:each) do
    CouchPotato::Config.validation_framework = @original_validation_framework
  end
  [:validatable, :active_model].each do |validation_framework|
    describe "with #{validation_framework}" do
      before(:each) do
        CouchPotato::Config.validation_framework = validation_framework
        @tree = Tree.new(:leaf_count => 1, :root_count => 1)
      end

      begin
        Object.send(:remove_const, :Tree) if Object.const_defined?(:Tree)
        class Tree
          include CouchPotato::Persistence

          before_validation :water!, lambda {|tree| tree.root_count += 1 }
  
          property :leaf_count
          property :root_count
  
          def water!
            self.leaf_count += 1
          end
        end

        it "should call water! when validated" do
          @tree.leaf_count.should == 1
          @tree.should be_valid
          @tree.leaf_count.should == 2
        end

        it "should call lambda when validated" do
          @tree.root_count.should == 1
          @tree.should be_valid
          @tree.root_count.should == 2
        end
      rescue LoadError
        STDERR.puts "WARNING: Skipping Callback unit tests with #{validation_framework} as it is not installed."
      end
    end
  end
end