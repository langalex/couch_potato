require 'rubygems'
require 'spec'

$:.unshift(File.dirname(__FILE__) + '/../lib')

require 'couch_potato'

CouchPotato::Config.database_name = 'couch_potato_test'


class Comment
  include CouchPotato::Persistence
  
  validates_presence_of :title
  
  property :title
  belongs_to :commenter
end

def recreate_db
  CouchPotato.couchrest_database.delete! rescue nil
  CouchPotato.couchrest_database.server.create_db CouchPotato::Config.database_name
end
recreate_db

Spec::Matchers.create :string_matching do |regex|
  match do |string|
    string =~ regex
  end
end
