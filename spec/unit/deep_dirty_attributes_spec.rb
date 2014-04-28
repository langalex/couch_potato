require 'spec_helper'

class Cover
  include CouchPotato::Persistence

  def initialize(*args)
    self._id = SecureRandom.uuid
    super
  end

  property :color
end

class Page
  include CouchPotato::Persistence

  def initialize(*args)
    self._id = SecureRandom.uuid
    super
  end

  property :number
  property :headline
end

class Book
  include CouchPotato::Persistence
  include CouchPotato::Persistence::DeepDirtyAttributes

  property :title
  property :cover, :type => Cover
  property :authors, :type => [String]
  property :pages, :type => [Page]
end

class TextBook < Book
  property :edition
end

describe "deep dirty attribute tracking" do
  describe "standard dirty checking" do
    describe "_changed?" do
      it "should return true if only root simple properties have changed" do
        book = Book.new(:title => "A")
        book.title = "B"
        book.should be_title_changed
        book.should be_changed
      end
    end

    describe "_was" do
      it "gives access to old values of simple root properties" do
        book = Book.new(:title => "A")
        book.title = "B"
        book.title_was.should == "A"
        book.title_change.should == ["A", "B"]
      end
    end

    describe "_change" do
      it "returns standard _change" do
        book = Book.new(:title => "A")
        book.title = "B"
        book.title_change.should == ["A", "B"]
      end
    end
  end

  describe "single nested document" do
    describe "_changed?" do
      it "should return true if a nested attribute has changed" do
        book = Book.new(:cover => Cover.new(:color => "red"))
        book.cover.color = "blue"
        book.should be_cover_changed
        book.should be_changed
      end

      it "should return true if changed to a different document" do
        book = Book.new(:cover => Cover.new(:color => "red"))
        book.cover = Cover.new(:color => "blue")
        book.should be_cover_changed
        book.should be_changed
      end

      it "should return false if changed to a clone of the original document" do
        book = Book.new(:cover => Cover.new(:color => "red"))
        book.cover = book.cover.clone
        book.should_not be_cover_changed
        book.should_not be_changed
      end

      it "should return false if set to nil and unchanged" do
        book = Book.new
        book.should_not be_cover_changed
        book.should_not be_changed
      end

      it "should return true when reassigned with changes but the same _id" do
        book = Book.new(:cover => Cover.new(:_id => "cid", :color => "red"))
        book.cover = Cover.new(:_id => "cid", :color => "blue")
        book.should be_cover_changed
        book.should be_changed
      end
    end

    describe "_was" do
      it "gives access to the old value" do
        book = Book.new(:cover => Cover.new(:color => "red"))
        book.cover.color = "blue"
        book.cover_was.color.should == "red"
      end
    end

    describe "_change" do
      it "should return the standard changes when a nested document is reassigned" do
        book = Book.new(:cover => Cover.new(:color => "red"))
        book.cover = Cover.new(:color => "blue")
        book.cover_change[0].should be_a Cover
        book.cover_change[0].color.should == "red"
        book.cover_change[1].should be_a Cover
        book.cover_change[1].color.should == "blue"
      end

      it "should return the standard changes when a nested document is reassigned from nil" do
        book = Book.new
        book.cover = Cover.new
        book.cover_change[0].should == nil
        book.cover_change[1].should == book.cover
      end

      it "should return the standard changes when a nested document is reassigned to nil" do
        cover = Cover.new
        book = Book.new(:cover => cover)
        book.cover = nil
        book.cover_change[0].should == cover
        book.cover_change[1].should == nil
      end

      it "should return the nested changes when a nested document is changed" do
        book = Book.new(:cover => Cover.new(:color => "red"))
        book.cover.color = "blue"
        book.cover_change[0].should be_a Cover
        book.cover_change[0].color.should == "red"
        book.cover_change[1].should == book.cover.changes
      end

      it "should return the nested changes when reassigned with changes but the same _id" do
        book = Book.new(:cover => Cover.new(:_id => "cid", :color => "red"))
        book.cover = Cover.new(:_id => "cid", :color => "blue")
        book.cover_change[0].should be_a Cover
        book.cover_change[0].color.should == "red"
        book.cover_change[1].should == {"color" => ["red", "blue"]}
      end
    end
  end

  describe "simple array" do
    describe "_changed?" do
      it "returns true if the array is reassigned" do
        book = Book.new(:authors => ["Sarah"])
        book.authors = ["Jane"]
        book.should be_authors_changed
      end

      it "returns true if an item is added" do
        book = Book.new(:authors => ["Jane"])
        book.authors << "Sue"
        book.should be_authors_changed
        book.should be_changed
      end

      it "returns true if an item is removed" do
        book = Book.new(:authors => ["Sue"])
        book.authors.delete "Sue"
        book.should be_authors_changed
        book.should be_changed
      end

      it "returns false if an empty array is unchanged" do
        book = Book.new(:authors => [])
        book.authors = []
        book.should_not be_authors_changed
        book.should_not be_changed
      end
    end

    describe "_was" do
      it "gives access to the old values" do
        book = Book.new(:authors => ["Jane"])
        book.authors << "Sue"
        book.authors_was.should == ["Jane"]
      end
    end

    describe "_change" do
      it "returns a hash of added and removed items" do
        book = Book.new(:authors => ["Jane"])
        book.authors << "Sue"
        book.authors.delete "Jane"
        book.authors_change[0].should == ["Jane"]
        book.authors_change[1].should be_a HashWithIndifferentAccess
        book.authors_change[1][:added].should == ["Sue"]
        book.authors_change[1][:removed].should == ["Jane"]
      end

      it "returns a hash of added and removed items when the array is reassigned" do
        book = Book.new(:authors => ["Jane"])
        book.authors = ["Sue"]
        book.authors_change[0].should == ["Jane"]
        book.authors_change[1].should be_a HashWithIndifferentAccess
        book.authors_change[1][:added].should == ["Sue"]
        book.authors_change[1][:removed].should == ["Jane"]
      end

      it "returns a hash of added items when the value is changed from nil to an array" do
        book = Book.new
        book.authors = ["Sue"]
        book.authors_change[0].should == []
        book.authors_change[1].should be_a HashWithIndifferentAccess
        book.authors_change[1][:added].should == ["Sue"]
        book.authors_change[1][:removed].should == []
      end

      it "returns a hash of removed items when the value is changed from an array to nil" do
        book = Book.new(:authors => ["Jane"])
        book.authors = nil
        book.authors_change[0].should == ["Jane"]
        book.authors_change[1].should be_a HashWithIndifferentAccess
        book.authors_change[1][:added].should == []
        book.authors_change[1][:removed].should == ["Jane"]
      end
    end
  end

  describe "document array" do
    describe "_changed?" do
      it "returns true if an item is changed" do
        book = Book.new(:pages => [Page.new(:number => 1)])
        book.pages[0].number = 2
        book.should be_pages_changed
        book.should be_changed
      end

      it "returns true if an item is added" do
        book = Book.new(:pages => [Page.new(:number => 1)])
        book.pages << Page.new(:number => 2)
        book.should be_pages_changed
        book.should be_changed
      end

      it "returns true if an items is removed" do
        book = Book.new(:pages => [Page.new(:number => 1)])
        book.pages.delete_at 0
        book.should be_pages_changed
        book.should be_changed
      end

      it "returns true if an item is replaced" do
        book = Book.new(:pages => [Page.new(:number => 1)])
        book.pages[0] = Page.new(:number => 2)
        book.should be_pages_changed
        book.should be_changed
      end

      it "returns false if an item is replaced with a clone" do
        book = Book.new(:pages => [Page.new(:number => 1)])
        book.pages[0] = book.pages[0].clone
        book.should_not be_pages_changed
        book.should_not be_changed
      end

      it "returns true if an item is replaced with changes but the same _id" do
        book = Book.new(:pages => [Page.new(:_id => "pid", :number => 1)])
        book.pages[0] = Page.new(:_id => "pid", :number => 2)
        book.should be_pages_changed
        book.should be_changed
      end

      it "returns false if an empty array is unchanged" do
        book = Book.new(:pages => [])
        book.pages = []
        book.should_not be_authors_changed
        book.should_not be_changed
      end
    end

    describe "_was" do
      it "gives access to the old values" do
        book = Book.new(:pages => [Page.new(:number => 1)])
        book.pages[0].number = 2
        book.pages_was[0].number.should == 1
      end
    end

    describe "_change" do
      it "returns a changes hash with added, removed, and changed items" do
        p1 = Page.new
        p2 = Page.new(:headline => "A")
        p3 = Page.new
        book = Book.new(:pages => [p1, p2])
        pages = book.pages.clone
        book.pages = [p2]
        p2.headline = "B"
        book.pages << p3
        book.pages_change[0].should == pages
        book.pages_change[1].should be_a HashWithIndifferentAccess
        book.pages_change[1][:added].should == [p3]
        book.pages_change[1][:removed].should == [p1]
        book.pages_change[1][:changed][0][0].should be_a Page
        book.pages_change[1][:changed][0][0].headline.should == "A"
        book.pages_change[1][:changed][0][1].should == p2.changes
      end

      it "returns added items when changing from nil to an array" do
        p1 = Page.new
        p2 = Page.new(:headline => "A")
        book = Book.new
        book.pages = [p1, p2]
        book.pages_change[0].should == []
        book.pages_change[1].should be_a HashWithIndifferentAccess
        book.pages_change[1][:added].should == [p1, p2]
        book.pages_change[1][:removed].should == []
        book.pages_change[1][:changed].should == []
      end

      it "does not return unchanged cloned items as changes" do
        book = Book.new(:pages => [Page.new(:number => 1)])
        book.pages[0] = book.pages[0].clone
        book.pages_change.should be_nil
      end

      it "returns changes if an item is replaced with changes but the same _id" do
        book = Book.new(:pages => [Page.new(:_id => "pid", :number => 1)])
        pages = book.pages.clone
        book.pages[0] = Page.new(:_id => "pid", :number => 2)
        book.pages_change[0].should == pages
        book.pages_change[1].should be_a HashWithIndifferentAccess
        book.pages_change[1][:added].should == []
        book.pages_change[1][:removed].should == []
        book.pages_change[1][:changed].should == [[pages[0], {"number" => [1, 2]}]]
      end
    end
  end

  describe "changes" do
    it "includes simple property changes" do
      book = Book.new(:title => "Title A")
      book.title = "Title B"
      book.changes[:title].should == book.title_change
    end

    it "includes embedded document changes" do
      book = Book.new(:cover => Cover.new(:color => "red"))
      cover = book.cover.clone
      book.cover.color = "blue"
      book.changes[:cover].should == book.cover_change
    end

    it "does not include unchanged embedded documents" do
      book = Book.new(:cover => Cover.new(:color => "red"))
      book.changes.should_not have_key :cover
    end

    it "includes simple array changes" do
      book = Book.new(:authors => ["Sarah"])
      book.authors = ["Jane"]
      book.changes[:authors].should == book.authors_change
    end

    it "does not include unchanged simple arrays" do
      book = Book.new(:authors => ["Sarah"])
      book.changes.should_not have_key :authors
    end

    it "includes document array changes" do
      book = Book.new(:pages => [Page.new(:number => 1)])
      book.pages = [Page.new(:number => 2)]
      book.changes[:pages].should == book.pages_change
    end

    it "does not include unchanged document arrays" do
      book = Book.new(:pages => [Page.new(:number => 1)])
      book.changes.should_not have_key :pages
    end
  end

  describe "after save" do
    before :each do
      book = Book.json_create(:_id => "1", :title => "A", :cover => {:color => "red"}, :pages => [{:_id => "p1", :number => 1}, {:_id => "p2", :number => 2}])
      @couchrest_db = stub('database', :info => nil, :save_doc => {}, :get => book)
      @db = CouchPotato::Database.new(@couchrest_db)
      @book = @db.load_document "1"
    end

    it "should reset all attributes to not dirty" do
      @book.title = "B"
      @book.cover.color = "blue"
      @db.save! @book
      @book.should_not be_dirty
      @book.cover.should_not be_dirty
    end

    it "should reset all elements in a document array" do
      @book.pages.each(&:is_dirty)
      @db.save! @book
      @book.should_not be_dirty
      @book.pages.each do |page|
        page.should_not be_dirty
      end
    end

    it "should reset a forced dirty state" do
      @book.is_dirty
      @db.save! @book
      @book.should_not be_dirty
    end

    it "clears old values" do
      @book.cover.color = "blue"
      @db.save! @book
      @book.cover_was.should be_nil
      @book.cover_change.should be_nil
    end
  end

  describe "on inherited models" do
    it "still uses deep dirty tracking" do
      book = TextBook.new(:pages => [Page.new(:number => 1)])
      book.pages[0].number = 2
      book.should be_pages_changed
      book.should be_changed
    end
  end
end
