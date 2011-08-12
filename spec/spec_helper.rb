require 'rubygems'
require 'rspec'
require 'time'
require 'active_support'
require 'timecop'

$:.unshift(File.dirname(__FILE__) + '/../lib')

require 'couch_potato'

CouchPotato::Config.database_name = ENV['DATABASE'] || 'couch_potato_test'

# silence deprecation warnings from ActiveModel as the Spec uses Errors#on
begin
  ActiveSupport::Deprecation.silenced = true
rescue
  # ignore errors, ActiveSupport is probably not installed
end

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

RSpec::Matchers.define :string_matching do |regex|
  match do |string|
    string =~ regex
  end
end
