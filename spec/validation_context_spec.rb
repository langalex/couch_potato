require 'spec_helper'

describe "validation context" do
  let(:db) { CouchPotato.database }

  context 'when calling save' do
    
    it 'uses the :create context on creation' do
      model = WithValidationContext.new

      db.save(model)

      expect(model.errors[:name]).to eq(["can't be blank"])
    end

    it 'uses the :update context on update' do
      model = WithValidationContext.new(name: 'initial name')
      db.save!(model)

      model.name = 'new'
      db.save(model)

      expect(model.errors[:name]).to eq(["is too short (minimum is 5 characters)"])
    end

    it 'uses a custom context on create when specified' do
      model = WithValidationContext.new(name: 'short')
      
      db.save(model, context: :custom)

      expect(model.errors[:name]).to eq(["is too short (minimum is 10 characters)"])
    end

    it 'uses a custom context on update when specified' do
      model = WithValidationContext.new(name: 'initial name')
      db.save!(model)

      model.name = 'new'
      db.save(model, context: :custom)

      expect(model.errors[:name]).to eq(["is too short (minimum is 10 characters)"])
    end

  end

  context 'when calling save!' do
    
    it 'uses the :create context on creation' do
      model = WithValidationContext.new

      expect do
        db.save!(model)
      end.to raise_error(CouchPotato::Database::ValidationsFailedError, /Name can't be blank/)
    end

    it 'uses the :update context on update' do
      model = WithValidationContext.new(name: 'initial name')
      db.save!(model)

      model.name = 'new'
      expect do
        db.save!(model)
      end.to raise_error(CouchPotato::Database::ValidationsFailedError, /Name is too short \(minimum is 5 characters\)/)
    end

    it 'uses a custom context on create when specified' do
      model = WithValidationContext.new(name: 'short')

      expect do
        db.save!(model, context: :custom)
      end.to raise_error(CouchPotato::Database::ValidationsFailedError, /Name is too short \(minimum is 10 characters\)/)
    end

    it 'uses a custom context on update when specified' do
      model = WithValidationContext.new(name: 'initial name')
      db.save!(model)

      model.name = 'new'
      expect do
        db.save!(model, context: :custom)
      end.to raise_error(CouchPotato::Database::ValidationsFailedError, /Name is too short \(minimum is 10 characters\)/)
    end
  end
end