require "spec_helper"

describe CouchPotato::View::Lists, ".list" do
  it "should make the list function available via .lists" do
    clazz = Class.new
    clazz.send :include, CouchPotato::View::Lists
    clazz.list "my_list", "<list_code>"

    expect(clazz.lists("my_list")).to eq("<list_code>")
  end

  it "should make the list available to subclasses" do
    clazz = Class.new
    clazz.send :include, CouchPotato::View::Lists
    clazz.list "my_list", "<list_code>"
    sub_clazz = Class.new clazz

    expect(sub_clazz.lists("my_list")).to eq("<list_code>")
  end
end
