require 'rubygems'
require 'active_support'
require 'json'
require 'json/add/core'
require 'json/add/rails'

require 'ostruct'

module CouchPotato
  Config = OpenStruct.new
end


require File.dirname(__FILE__) + '/couch_potato/persistence'
require File.dirname(__FILE__) + '/couch_potato/versioning'
require File.dirname(__FILE__) + '/couch_potato/active_record/compatibility'
require File.dirname(__FILE__) + '/couch_potato/core_ext/time'
