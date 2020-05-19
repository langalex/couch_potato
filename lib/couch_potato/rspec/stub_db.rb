# frozen_string_literal: true

require 'rspec/mocks'
require 'active_support/core_ext/array'

module CouchPotato::RSpec
  module StubView
    class ViewStub
      include RSpec::Mocks::ExampleMethods

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
        view_stub = double("#{@clazz}.#{@view}(#{@args.try(:join, ', ')}) view")
        stub = allow(@clazz).to receive(@view)
        stub.with(*@args) if @args
        stub.and_return(view_stub)
        allow(@db).to receive(:view).with(view_stub).and_return(return_value)
        return unless return_value.respond_to?(:first)

        allow(@db).to receive(:first).with(view_stub).and_return(return_value.first)
        allow(@db)
          .to receive(:view_in_batches) do |_view, batch_size: CouchPotato::Database.default_batch_size, &block|
            batches = return_value.in_groups_of(batch_size, false)
            batches.each(&block)
          end
          .with(view_stub, any_args)

        if return_value.first
          allow(@db).to receive(:first!).with(view_stub).and_return(return_value.first)
        else
          allow(@db).to receive(:first!).with(view_stub).and_raise(CouchPotato::NotFound)
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
    include ::RSpec::Mocks::ExampleMethods

    def stub_db(options = {})
      db = double(:db, options)
      db.extend CouchPotato::RSpec::StubView
      allow(self).to receive(:database) { db }
      db
    end
  end

  ::CouchPotato.extend StubDb
end
