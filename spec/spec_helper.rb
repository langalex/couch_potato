require 'rubygems'
gem 'rspec'
require 'spec'

$:.unshift(File.dirname(__FILE__) + '/../lib')

require 'couch_potatoe'

CouchPotatoe::Config.database_name = 'couchpotatoe_test'
CouchPotatoe::Persistence.Db.delete!

class User
  include CouchPotatoe::Persistence
  
  has_many :comments
end

class Comment
  include CouchPotatoe::Persistence
  
  property :title
end
