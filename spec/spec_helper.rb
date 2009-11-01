require 'rubygems'
require 'spec'

$:.unshift(File.dirname(__FILE__) + '/../lib')

require 'couch_potato'

CouchPotato::Config.database_name = 'couch_potato_test'

class Child
  include CouchPotato::Persistence

  property :text
end



class Comment
  include CouchPotato::Persistence

  validates_presence_of :title

  property :title
end

def recreate_db
  CouchPotato.couchrest_database.recreate!
end
recreate_db

Spec::Matchers.define :string_matching do |regex|
  match do |string|
    string =~ regex
  end
end
