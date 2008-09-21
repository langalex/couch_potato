require 'active_support'
require 'json'
require 'json/add/core'
require 'json/add/rails'

require 'ostruct'

module CouchPotatoe
  Config = OpenStruct.new
end


require File.dirname(__FILE__) + '/couch_potatoe/persistence'
require File.dirname(__FILE__) + '/couch_potatoe/core_ext/time'
