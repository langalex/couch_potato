require "spec_helper"

class Document
  include CouchPotato::Persistence

  property :title
  property :content
end

describe "new" do
  context "without arguments" do
    subject { Document.new }

    it { is_expected.to be_a(Document) }

    it "has no title" do
      expect(subject.title).to be_nil
    end

    it "has no content" do
      expect(subject.content).to be_nil
    end
  end

  context "with an argument hash" do
    subject { Document.new(title: "My Title") }

    it { is_expected.to be_a(Document) }

    it "has a title" do
      expect(subject.title).to eql("My Title")
    end

    it "has no content" do
      expect(subject.content).to be_nil
    end
  end

  context "yielding to a block" do
    subject do
      Document.new(title: "My Title") do |doc|
        doc.content = "My Content"
      end
    end

    it { is_expected.to be_a(Document) }

    it "has a title" do
      expect(subject.title).to eql("My Title")
    end

    it "has a content" do
      expect(subject.content).to eql("My Content")
    end
  end
end
