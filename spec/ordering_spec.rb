require File.dirname(__FILE__) + '/spec_helper'


describe CouchPotato::Ordering do
  
  class Album
    include CouchPotato::Persistence
    has_many :photos
  end
  
  class Photo
    include CouchPotato::Persistence
    include CouchPotato::Ordering
    set_ordering_scope :album_id
    belongs_to :album
  end
  
  before(:each) do
    CouchPotato::Persistence.Db.delete!
    @album = Album.create!
  end
  
  describe "create" do
    it "should add a position" do
      photo = @album.photos.create!
      photo.position.should == 1
    end
    
    it "should increase the position when adding a second item" do
      @album.photos.create!
      photo = @album.photos.create!
      photo.position.should == 2
    end
  end
  
  describe 'insert' do
    it "should increse the position of the items that are now lower than this" do
      photo1 = @album.photos.create!
      photo2 = @album.photos.create! :position => 1
      CouchPotato::Persistence.Db.get(photo1._id)['position'].should == 2
    end
  end
  
  describe "decrease position" do
    it "should increase the position of the items that are now lower than this" do
      photo1 = @album.photos.create!
      photo2 = @album.photos.create!
      photo2.position = 1
      photo2.save!
      CouchPotato::Persistence.Db.get(photo1._id)['position'].should == 2
    end
  end
  
  describe "increase position" do
    it "should decrease the position of the items that are now higher than this" do
      photo1 = @album.photos.create!
      photo2 = @album.photos.create!
      photo1.position = 2
      photo1.save!
      CouchPotato::Persistence.Db.get(photo2._id)['position'].should == 1
    end
  end
  
  it "should order by position" do
    @album.photos.create!
    @album.photos.create! :position => 1
    @album = Album.get @album._id
    @album.photos.map(&:position).should == [1,2]
  end
  
  describe "destroy" do
    it "should decrease the position of the lower items" do
      photo1 = @album.photos.create!
      photo2 = @album.photos.create!
      photo1.destroy
      CouchPotato::Persistence.Db.get(photo2._id)['position'].should == 1
    end
  end
  
  describe "scoping" do
    it "should only update objects within the scope" do
      photo1 = @album.photos.create!
      photo2 = @album.photos.create!
      album2 = Album.create!
      album2.photos.create!
      
      photo2.position = 1
      photo2.save!
      
      album2.photos.first.position.should == 1
    end
  end
  
end