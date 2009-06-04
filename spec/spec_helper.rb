require 'rubygems'
require 'spec'

$:.unshift(File.dirname(__FILE__) + '/../lib')

require 'couch_potato'

CouchPotato::Config.database_name = 'couch_potato_test'
CouchPotato::Config.database_server = 'http://192.168.1.48:5984/'


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

Spec::Matchers.define :string_matching do |regex|
  match do |string|
    string =~ regex
  end
end
