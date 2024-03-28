require "spec_helper"

describe Date, "to_json" do
  it "should format the date in a way that i can use it for sorting in couchdb" do
    date = Date.parse("2009-01-01")
    expect(date.to_json).to eq("\"2009/01/01\"")
  end
end

describe Date, "as_json" do
  it "should format it in the same way as to_json does so i can use this to do queries over date attributes" do
    date = Date.parse("2009-01-01")
    expect(date.as_json).to eq("2009/01/01")
  end
end

describe Date, "to_s" do
  it "should leave the original to_s untouched" do
    date = Date.parse("2009-01-01")
    expect(date.to_s).to eq("2009-01-01")
  end
end
