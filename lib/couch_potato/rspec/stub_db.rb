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

      def and_return(*return_values)
        view_stub = double("#{@clazz}.#{@view}(#{@args.try(:join, ', ')}) view")
        stub = allow(@clazz).to receive(@view)
        stub.with(*@args) if @args
        stub.and_return(view_stub)

        view_return_values = return_values.map do |return_value|
          if flex_view? && return_value.is_a?(Array)
            stub_flex_results(return_value)
          else
            return_value
          end
        end
        allow(@db).to receive(:view).with(view_stub).and_return(*view_return_values)
        return unless return_values.all? { |v| v.respond_to?(:first) }

        allow(@db).to receive(:first).with(view_stub).and_return(*return_values.map(&:first))
        remaining_for_batches = return_values.dup
        allow(@db)
          .to receive(:view_in_batches) do |_view, batch_size: CouchPotato::Database.default_batch_size, &block|
            return_value = remaining_for_batches.size > 1 ? remaining_for_batches.shift : remaining_for_batches.first
            batches = return_value.in_groups_of(batch_size, false)
            batches.each(&block)
          end
          .with(view_stub, any_args)

        remaining_for_first = return_values.dup
        allow(@db).to receive(:first!).with(view_stub) do
          return_value = remaining_for_first.size > 1 ? remaining_for_first.shift : remaining_for_first.first
          raise CouchPotato::NotFound unless return_value.first

          return_value.first
        end
      end

      private

      def flex_view?
        @clazz.execute_view(@view.to_s, {}).is_a?(CouchPotato::View::FlexViewSpec)
      end

      def stub_flex_results(docs)
        instance_double(CouchPotato::View::FlexViewSpec::Results, docs:)
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
