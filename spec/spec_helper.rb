require 'rubygems'
gem 'rspec'
require 'spec'

$:.unshift(File.dirname(__FILE__) + '/../lib')

require 'couch_potatoe'

CouchPotatoe::Config.database_name = 'couchpotatoe_test'
CouchPotatoe::Persistence.Db.delete!

class User
  include CouchPotatoe::Persistence
  
  has_many :comments, :stored => :inline
end

class Commenter
  include CouchPotatoe::Persistence
  
  has_many :comments, :stored => :separately
end

class Comment
  include CouchPotatoe::Persistence
  
  validates_presence_of :title
  
  property :title
  belongs_to :commenter
end
