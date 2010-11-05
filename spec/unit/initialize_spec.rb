require 'spec_helper'

class Document
  include CouchPotato::Persistence
  
  property :title
  property :content
end

describe "new" do
  context "without arguments" do
    subject { Document.new }

    it { should be_a(Document) }
    its(:title) { should be_nil }
    its(:content) { should be_nil }
  end

  context "with an argument hash" do
    subject { Document.new(:title => 'My Title') }

    it { should be_a(Document) }
    its(:title) { should == 'My Title'}
    its(:content) { should be_nil }
  end

  context "yielding to a block" do
    subject {
      Document.new(:title => 'My Title') do |doc|
        doc.content = 'My Content'
      end
    }

    it { should be_a(Document) }
    its(:title) { should == 'My Title'}
    its(:content) { should == 'My Content'}
  end
end