require 'spec_helper'

describe Time, 'to_json' do
  it "should convert to utc and format the time in a way that i can use it for sorting in couchdb" do
    time = Time.parse('2009-01-01 11:12:23 +0200')
    time.to_json.should == "\"2009/01/01 09:12:23 +0000\""
  end
end

describe Time, 'as_json' do
  it "should format it in the same way as to_json does so i can use this to do queries over time attributes" do
    time = Time.parse('2009-01-01 11:12:23 +0200')
    time.as_json.should == "2009/01/01 09:12:23 +0000"
  end
end
