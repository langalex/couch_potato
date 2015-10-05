require 'spec_helper'

begin
  require 'rack/test'
  require 'active_model/forbidden_attributes_protection'
  require 'action_controller/metal/strong_parameters'

  describe 'forbidden attributes protection' do
    context 'when initializing a new object' do
      it 'raises an error when passing non-permitted attributes' do
        expect {
          Child.new ActionController::Parameters.new(:text => 'xx')
        }.to raise_error(ActiveModel::ForbiddenAttributesError)
      end

      it 'raises no error when passing permitted attributes' do
        expect {
          Child.new ActionController::Parameters.new(:text => 'xx').permit!
        }.to_not raise_error
      end

      it "raises no error when passing attributes that don't respond to permitted?" do
        expect {
          Child.new :text => 'xx'
        }.to_not raise_error
      end
    end

    context 'when mass-assigning attributes to an object' do
      let(:subject) {Child.new}

      it 'raises an error when passing non-permitted attributes' do
        expect {
          subject.attributes = ActionController::Parameters.new(:text => 'xx')
        }.to raise_error(ActiveModel::ForbiddenAttributesError)
      end

      it 'raises no error when passing permitted attributes' do
        expect {
          subject.attributes = ActionController::Parameters.new(:text => 'xx').permit!
        }.to_not raise_error
      end

      it "raises no error when passing attributes that don't respond to permitted?" do
        expect {
          subject.attributes = {:text => 'xx'}
        }.to_not raise_error
      end
    end
  end
rescue LoadError
  puts "Skipping forbidden attributes protection specs."
end
