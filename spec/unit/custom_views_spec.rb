require "spec_helper"

describe CouchPotato::View::CustomViews do
  class MyViewSpec; end

  class ModelWithView
    include CouchPotato::Persistence
    view :all, type: MyViewSpec
  end

  it "should use a custom viewspec class" do
    expect(MyViewSpec).to receive(:new)
    ModelWithView.all
  end
end
