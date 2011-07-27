module CouchPotato::RSpec
  
  module StubView
    class ViewStub
      def initialize(clazz, view, db)
        @clazz = clazz
        @view = view
        @db = db
      end
    
      def with(*args, &block)
        @args = args
        and_return(block.call) if block
        self
      end

      def and_return(return_value)
        view_stub = RSpec::Mocks::Mock.new("#{@clazz}.#{@view}(#{@args.try(:join, ', ')}) view")
        _stub = @clazz.stub(@view)
        _stub.with(*@args) if @args
        _stub.and_return(view_stub)
        @db.stub(:view).with(view_stub).and_return(return_value)
        if return_value.respond_to?(:first)
          @db.stub(:first).with(view_stub).and_return(return_value.first)
          if return_value.first
            @db.stub(:first!).with(view_stub).and_return(return_value.first)
          else
            @db.stub(:first!).with(view_stub).and_raise(CouchPotato::NotFound)
          end
        end
      end
    end

    def stub_view(clazz, view, &block)
      stub = ViewStub.new clazz, view, self
      stub.and_return(block.call) if block
      stub
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

module RSpec
  module Mocks
    module ExampleMethods
      include CouchPotato::RSpec::StubDb
    end
  end
end