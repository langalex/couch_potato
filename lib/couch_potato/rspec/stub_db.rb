module CouchPotato::RSpec
  
  module StubView
    class ViewStub
      def initialize(clazz, view, db)
        @clazz = clazz
        @view = view
        @db = db
      end
    
      def with(*args)
        @args = args
        self
      end

      def and_return(return_value)
        view_stub = Spec::Mocks::Mock.new("#{@clazz}.#{@view}(#{@args.try(:join, ', ')}) view")
        _stub = @clazz.stub(@view)
        _stub.with(*@args) if @args
        _stub.and_return(view_stub)
        @db.stub(:view).with(view_stub).and_return(return_value)
      end
    end

    def stub_view(clazz, view)
      ViewStub.new clazz, view, self
    end
  end

  module StubDb
    def stub_db(options = {})
      db = stub('db', options)
      db.extend CouchPotato::RSpec::StubView
      CouchPotato.stub(:database => db)
      db
    end
  end
end

module Spec
  module Mocks
    module ExampleMethods
      include CouchPotato::RSpec::StubDb
    end
  end
end