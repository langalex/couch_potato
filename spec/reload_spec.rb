require 'spec_helper'

describe CouchPotato::Persistence, '#reload' do
  let(:db) { CouchPotato.database }

  it 'returns a new instance from the database' do
    comment = Comment.new title: 'hello'
    db.save! comment

    reloaded = comment.reload
    expect(reloaded.object_id).to_not eql(comment.object_id)
    expect(reloaded).to eql(comment)
  end
end
