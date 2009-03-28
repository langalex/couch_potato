require 'active_support'
require 'couchrest'
require 'json'
require 'json/add/core'
require 'json/add/rails'

require 'ostruct'

require 'validatable'


module CouchPotato
  Config = OpenStruct.new
end

require File.dirname(__FILE__) + '/core_ext/object'
require File.dirname(__FILE__) + '/core_ext/time'
require File.dirname(__FILE__) + '/couch_potato/persistence'
require File.dirname(__FILE__) + '/couch_potato/active_record/compatibility'

